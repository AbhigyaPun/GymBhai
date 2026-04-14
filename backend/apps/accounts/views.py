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
from .models import Member, Attendance, Feedback
from .serializers import (
    MemberSerializer, CreateMemberSerializer,
    UpdateMemberSerializer, AdminLoginSerializer,
    AttendanceSerializer, FeedbackSerializer,
    CreateFeedbackSerializer,
)
from datetime import date
from django.utils import timezone



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
    permission_classes = [IsAuthenticated]

    def get(self, request):
        member = request.user.member
        payload = f"GYMBHAI:{member.id}:{member.qr_token}:{member.phone}"
        signature = hmac.new(
            settings.SECRET_KEY.encode(),
            payload.encode(),
            hashlib.sha256
        ).hexdigest()
        qr_data = f"{payload}:{signature}"
        return Response({'qr_data': qr_data})


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
    permission_classes = [IsAdminUser]

    def post(self, request):
        qr_data = request.data.get('qr_data', '')
        parts = qr_data.split(':')
        
        # Now expects: GYMBHAI:member_id:qr_token:phone:signature
        if len(parts) != 5 or parts[0] != 'GYMBHAI':
            return Response({'error': 'Invalid QR code'}, status=400)

        _, member_id, qr_token, phone, signature = parts

        try:
            member = Member.objects.get(id=member_id)
        except Member.DoesNotExist:
            return Response({'error': 'Member not found'}, status=404)

        # Verify phone matches
        if member.phone != phone:
            return Response({'error': 'Invalid QR code'}, status=400)

        # Verify signature
        payload = f"GYMBHAI:{member_id}:{qr_token}:{phone}"
        expected = hmac.new(
            settings.SECRET_KEY.encode(),
            payload.encode(),
            hashlib.sha256
        ).hexdigest()

        if not hmac.compare_digest(signature, expected):
            return Response({'error': 'Invalid QR signature'}, status=400)

        if member.qr_token != qr_token:
            return Response({'error': 'QR token mismatch'}, status=400)

        # Check membership validity
        if member.expiry_date and member.expiry_date < date.today():
            member.status = 'expired'
            member.save()
            return Response({'error': 'Membership has expired. Please renew.'}, status=403)

        if member.status == 'expired':
            return Response({'error': 'Membership has expired. Please renew.'}, status=403)

        if member.status == 'frozen':
            return Response({'error': 'Membership is frozen. Contact admin.'}, status=403)

        # Record attendance
        today = date.today()
        attendance, created = Attendance.objects.get_or_create(
            member=member,
            checked_in__date=today,
            defaults={'checked_in': timezone.now()}
        )
        if not created:
            return Response({'message': 'Already checked in today',
                           'member': member.user.get_full_name()})

        return Response({'message': 'Check-in successful',
                'member': member.user.get_full_name()}, status=201)

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

class MemberFeedbackView(APIView):
    """Member submits feedback"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            member = request.user.member
        except Member.DoesNotExist:
            return Response({'error': 'No member account'},
                            status=status.HTTP_403_FORBIDDEN)
        serializer = CreateFeedbackSerializer(data=request.data)
        if serializer.is_valid():
            feedback = Feedback.objects.create(
                member=member, **serializer.validated_data)
            return Response(FeedbackSerializer(feedback).data,
                            status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        """Member sees their own feedback history"""
        try:
            member = request.user.member
        except Member.DoesNotExist:
            return Response({'error': 'No member account'},
                            status=status.HTTP_403_FORBIDDEN)
        feedbacks = Feedback.objects.filter(member=member)
        return Response(FeedbackSerializer(feedbacks, many=True).data)


class AdminFeedbackView(APIView):
    """Admin sees and manages all feedback"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        feedbacks = Feedback.objects.select_related(
            'member__user').all()
        return Response(FeedbackSerializer(feedbacks, many=True).data)


class AdminFeedbackDetailView(APIView):
    """Admin updates feedback status"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def patch(self, request, pk):
        try:
            feedback = Feedback.objects.get(pk=pk)
        except Feedback.DoesNotExist:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)
        new_status = request.data.get('status')
        if new_status not in ['pending', 'reviewed', 'resolved']:
            return Response({'error': 'Invalid status'},
                            status=status.HTTP_400_BAD_REQUEST)
        feedback.status = new_status
        feedback.save()
        return Response(FeedbackSerializer(feedback).data)

    def delete(self, request, pk):
        try:
            feedback = Feedback.objects.get(pk=pk)
        except Feedback.DoesNotExist:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)
        feedback.delete()
        return Response({'message': 'Deleted'},
                        status=status.HTTP_204_NO_CONTENT)
    
class MemberProfileView(APIView):
    """Member views and updates their own profile"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            member = request.user.member
        except Member.DoesNotExist:
            return Response({'error': 'No member account'},
                            status=status.HTTP_404_NOT_FOUND)
        return Response(MemberSerializer(member).data)

    def put(self, request):
        try:
            member = request.user.member
        except Member.DoesNotExist:
            return Response({'error': 'No member account'},
                            status=status.HTTP_404_NOT_FOUND)
        serializer = UpdateMemberSerializer(
            data=request.data,
            context={'member': member}
        )
        if serializer.is_valid():
            member = serializer.update(member, serializer.validated_data)
            # Update stored member data in response
            return Response(MemberSerializer(member).data)
        return Response(serializer.errors,
                        status=status.HTTP_400_BAD_REQUEST)
    
class AdminDashboardStatsView(APIView):
    """Real stats for admin dashboard"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        from django.utils import timezone
        from datetime import timedelta
        from django.db.models import Count

        now = timezone.now()
        today = now.date()
        month_start = now.replace(day=1, hour=0, minute=0,
                                   second=0, microsecond=0)

        # Member stats
        total_members  = Member.objects.count()
        active_members = Member.objects.filter(status='active').count()
        new_this_month = Member.objects.filter(
            member_since__gte=month_start.date()).count()

        # Membership breakdown
        basic_count    = Member.objects.filter(membership='basic').count()
        standard_count = Member.objects.filter(membership='standard').count()
        premium_count  = Member.objects.filter(membership='premium').count()

        # Today's attendance
        today_checkins = Attendance.objects.filter(
            checked_in__date=today).count()

        # Weekly attendance (last 7 days)
        weekly = []
        for i in range(6, -1, -1):
            day = today - timedelta(days=i)
            count = Attendance.objects.filter(
                checked_in__date=day).count()
            weekly.append({
                'day': day.strftime('%a'),
                'count': count,
            })

        # Expiring soon (next 7 days)
        expiring = Member.objects.filter(
            expiry_date__gte=today,
            expiry_date__lte=today + timedelta(days=7),
            status='active',
        ).select_related('user').order_by('expiry_date')[:5]

        expiring_data = [{
            'id':          m.id,
            'name':        m.user.get_full_name() or m.user.username,
            'membership':  m.membership,
            'expiry_date': str(m.expiry_date),
        } for m in expiring]

        # Recent activity (last 8 check-ins)
        recent_checkins = Attendance.objects.select_related(
            'member__user').all()[:8]
        recent_data = [{
            'name':       a.member.user.get_full_name() or
                          a.member.user.username,
            'membership': a.member.membership,
            'checked_in': a.checked_in.isoformat(),
        } for a in recent_checkins]

        # Monthly revenue
        try:
            from apps.memberships.models import Payment
            from django.db.models import Sum
            monthly_revenue = Payment.objects.filter(
                paid_at__gte=month_start
            ).aggregate(total=Sum('amount'))['total'] or 0
        except Exception:
            monthly_revenue = 0

        # Peak hour today
        from django.db.models.functions import ExtractHour
        peak = Attendance.objects.filter(
            checked_in__date=today
        ).annotate(
            hour=ExtractHour('checked_in')
        ).values('hour').annotate(
            count=Count('id')
        ).order_by('-count').first()

        peak_hour = None
        if peak:
            h = peak['hour']
            suffix = 'AM' if h < 12 else 'PM'
            h12 = h if h <= 12 else h - 12
            if h12 == 0: h12 = 12
            peak_hour = f"{h12}{suffix}"

        return Response({
            'total_members':   total_members,
            'active_members':  active_members,
            'new_this_month':  new_this_month,
            'today_checkins':  today_checkins,
            'monthly_revenue': monthly_revenue,
            'membership_breakdown': {
                'basic':    basic_count,
                'standard': standard_count,
                'premium':  premium_count,
            },
            'weekly_attendance': weekly,
            'expiring_soon':     expiring_data,
            'recent_checkins':   recent_data,
            'peak_hour':         peak_hour,
        })
    
class ManualAttendanceView(APIView):
    permission_classes = [IsAdminUser]

    def post(self, request):
        phone = request.data.get('phone', '').strip()
        if not phone:
            return Response({'error': 'Phone number is required'}, status=400)

        try:
            member = Member.objects.get(phone=phone)
        except Member.DoesNotExist:
            return Response({'error': 'No member found with this phone number'}, status=404)

        # Check membership validity
        if member.expiry_date and member.expiry_date < date.today():
            member.status = 'expired'
            member.save()
            return Response({'error': 'Membership has expired. Please renew.'}, status=403)

        if member.status == 'expired':
            return Response({'error': 'Membership has expired. Please renew.'}, status=403)

        if member.status == 'frozen':
            return Response({'error': 'Membership is frozen. Contact admin.'}, status=403)

        # Record attendance
        today = date.today()
        attendance, created = Attendance.objects.get_or_create(
            member=member,
            checked_in__date=today,
            defaults={'checked_in': timezone.now()}
        )
        if not created:
            return Response({'message': 'Already checked in today',
                           'member': member.user.get_full_name()})

        return Response({'message': 'Check-in successful',
                'member': member.user.get_full_name()}, status=201)
    
class GymBusyStatusView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from django.utils import timezone
        now = timezone.localtime()
        current_hour = now.hour

        # Count check-ins in the current hour
        current_count = Attendance.objects.filter(
            checked_in__date=now.date(),
            checked_in__hour=current_hour
        ).count()

        # Determine status
        if current_count == 0:
            status = 'quiet'
            label = 'Gym is Quiet'
            emoji = '🟢'
        elif current_count <= 10:
            status = 'moderate'
            label = 'Gym is Moderately Busy'
            emoji = '🟡'
        else:
            status = 'busy'
            label = 'Gym is Very Busy'
            emoji = '🔴'

        return Response({
            'status': status,
            'label': label,
            'emoji': emoji,
            'count': current_count,
            'hour': current_hour
        })
    
class SendExpiryRemindersView(APIView):
    permission_classes = [IsAdminUser]

    def post(self, request):
        from django.core.mail import send_mail
        from django.conf import settings
        today = timezone.now().date()
        reminder_date = today + timezone.timedelta(days=7)

        members = Member.objects.filter(
            expiry_date__lte=reminder_date,
            expiry_date__gte=today,
            status='active'
        )

        sent = 0
        failed = 0
        for member in members:
            days_left = (member.expiry_date - today).days
            try:
                send_mail(
                    subject=f'⚠️ GymBhai — Membership Expiring in {days_left} Days',
                    message=f'''Hi {member.user.first_name},

Your GymBhai membership is expiring in {days_left} day{'s' if days_left != 1 else ''} on {member.expiry_date}.

Please renew your membership to continue enjoying our facilities.

Plan: {member.membership.capitalize()}
Expiry Date: {member.expiry_date}

Contact your gym admin to renew.

— GymBhai Team''',
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[member.user.email],
                    fail_silently=False,
                )
                sent += 1
            except Exception as e:
                print(f'Failed to send to {member.user.email}: {e}')
                failed += 1

        return Response({
            'message': f'Reminders sent successfully',
            'sent': sent,
            'failed': failed,
            'total_expiring': members.count()
        })