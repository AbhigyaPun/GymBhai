import hmac
import hashlib
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from .models import Member, Attendance
from .serializers import (
    MemberSerializer, CreateMemberSerializer,
    UpdateMemberSerializer, AdminLoginSerializer,
    AttendanceSerializer,
)


def _make_signature(member_id: int, qr_token: str) -> str:
    """HMAC-SHA256 signature using Django SECRET_KEY"""
    message = f"{member_id}:{qr_token}".encode()
    return hmac.new(
        settings.SECRET_KEY.encode(),
        message,
        hashlib.sha256
    ).hexdigest()


class AdminLoginView(APIView):
    """Admin login - returns JWT tokens"""
    permission_classes = []

    def post(self, request):
        serializer = AdminLoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email    = serializer.validated_data['email']
        password = serializer.validated_data['password']

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'error': 'Invalid email or password'}, status=status.HTTP_401_UNAUTHORIZED)

        user = authenticate(username=user.username, password=password)
        if not user:
            return Response({'error': 'Invalid email or password'}, status=status.HTTP_401_UNAUTHORIZED)

        if not user.is_staff:
            return Response({'error': 'You do not have admin access'}, status=status.HTTP_403_FORBIDDEN)

        refresh = RefreshToken.for_user(user)
        return Response({
            'access':  str(refresh.access_token),
            'refresh': str(refresh),
            'user': {
                'id':    user.id,
                'email': user.email,
                'name':  user.get_full_name() or user.username,
            }
        })


class MemberLoginView(APIView):
    """Member login for Flutter mobile app"""
    permission_classes = []

    def post(self, request):
        serializer = AdminLoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email    = serializer.validated_data['email']
        password = serializer.validated_data['password']

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'error': 'Invalid email or password'}, status=status.HTTP_401_UNAUTHORIZED)

        user = authenticate(username=user.username, password=password)
        if not user:
            return Response({'error': 'Invalid email or password'}, status=status.HTTP_401_UNAUTHORIZED)

        try:
            member = user.member
        except Member.DoesNotExist:
            return Response({'error': 'No member account found'}, status=status.HTTP_403_FORBIDDEN)

        if member.status == 'expired':
            return Response({'error': 'Your membership has expired.'}, status=status.HTTP_403_FORBIDDEN)
        if member.status == 'frozen':
            return Response({'error': 'Your membership is frozen.'}, status=status.HTTP_403_FORBIDDEN)

        refresh = RefreshToken.for_user(user)
        return Response({
            'access':  str(refresh.access_token),
            'refresh': str(refresh),
            'member':  MemberSerializer(member).data
        })


class MemberQRView(APIView):
    """Return QR payload for the logged-in member (Flutter uses this)"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            member = request.user.member
        except Member.DoesNotExist:
            return Response({'error': 'No member account found'}, status=status.HTTP_404_NOT_FOUND)

        signature = _make_signature(member.id, member.qr_token)
        qr_data   = f"GYMBHAI:{member.id}:{member.qr_token}:{signature}"

        return Response({
            'qr_data':   qr_data,
            'member_id': member.id,
            'name':      request.user.get_full_name() or request.user.username,
        })


class MemberAttendanceView(APIView):
    """Return attendance records for the logged-in member (Flutter uses this)"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            member = request.user.member
        except Member.DoesNotExist:
            return Response({'error': 'No member account found'}, status=status.HTTP_404_NOT_FOUND)

        records = Attendance.objects.filter(member=member).order_by('-checked_in')[:90]
        dates = [r.checked_in.strftime('%Y-%m-%d') for r in records]
        return Response({
            'total': records.count(),
            'dates': dates,
        })


class AttendanceScanView(APIView):
    """Admin scans QR → verify → record attendance"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def post(self, request):
        qr_data = request.data.get('qr_data', '').strip()

        # ── Parse QR string ──────────────────────────────
        try:
            prefix, member_id_str, qr_token, received_sig = qr_data.split(':')
            if prefix != 'GYMBHAI':
                raise ValueError
            member_id = int(member_id_str)
        except (ValueError, AttributeError):
            return Response({'error': 'Invalid QR code format'}, status=status.HTTP_400_BAD_REQUEST)

        # ── Verify signature ─────────────────────────────
        expected_sig = _make_signature(member_id, qr_token)
        if not hmac.compare_digest(expected_sig, received_sig):
            return Response({'error': 'QR code signature is invalid'}, status=status.HTTP_400_BAD_REQUEST)

        # ── Get member ───────────────────────────────────
        try:
            member = Member.objects.select_related('user').get(id=member_id, qr_token=qr_token)
        except Member.DoesNotExist:
            return Response({'error': 'Member not found'}, status=status.HTTP_404_NOT_FOUND)

        # ── Membership rules ─────────────────────────────
        if member.status == 'expired':
            return Response({
                'error':  'Membership expired',
                'member': MemberSerializer(member).data,
            }, status=status.HTTP_403_FORBIDDEN)

        if member.status == 'frozen':
            return Response({
                'error':  'Membership is frozen',
                'member': MemberSerializer(member).data,
            }, status=status.HTTP_403_FORBIDDEN)

        # ── Record attendance ────────────────────────────
        attendance = Attendance.objects.create(member=member)

        return Response({
            'success':    True,
            'message':    f"Welcome, {member.user.get_full_name() or member.user.username}!",
            'member':     MemberSerializer(member).data,
            'checked_in': attendance.checked_in,
        }, status=status.HTTP_201_CREATED)


class AttendanceListView(APIView):
    """List all attendance records (admin only)"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        records = Attendance.objects.select_related('member__user').all()[:100]
        return Response(AttendanceSerializer(records, many=True).data)


class MemberListCreateView(APIView):
    """List all members or create a new member"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        members = Member.objects.select_related('user').all().order_by('-created_at')
        return Response(MemberSerializer(members, many=True).data)

    def post(self, request):
        serializer = CreateMemberSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        member = serializer.save()
        return Response(MemberSerializer(member).data, status=status.HTTP_201_CREATED)


class MemberDetailView(APIView):
    """Retrieve, update or delete a member"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get_object(self, pk):
        try:
            return Member.objects.select_related('user').get(pk=pk)
        except Member.DoesNotExist:
            return None

    def get(self, request, pk):
        member = self.get_object(pk)
        if not member:
            return Response({'error': 'Member not found'}, status=status.HTTP_404_NOT_FOUND)
        return Response(MemberSerializer(member).data)

    def put(self, request, pk):
        member = self.get_object(pk)
        if not member:
            return Response({'error': 'Member not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = UpdateMemberSerializer(data=request.data, context={'member': member})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        member = serializer.update(member, serializer.validated_data)
        return Response(MemberSerializer(member).data)

    def delete(self, request, pk):
        member = self.get_object(pk)
        if not member:
            return Response({'error': 'Member not found'}, status=status.HTTP_404_NOT_FOUND)
        member.user.delete()
        return Response({'message': 'Member deleted successfully'}, status=status.HTTP_204_NO_CONTENT)