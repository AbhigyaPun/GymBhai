from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import ProgressProfile, WeightLog
from .serializers import (
    ProgressProfileSerializer,
    UpdateProgressProfileSerializer,
    CreateWeightLogSerializer,
    WeightLogSerializer,
)


class MemberProgressView(APIView):
    """Get or update member progress profile"""
    permission_classes = [IsAuthenticated]

    def _get_or_create_profile(self, request):
        try:
            member = request.user.member
        except:
            return None, Response({'error': 'No member account'},
                                  status=status.HTTP_403_FORBIDDEN)
        profile, _ = ProgressProfile.objects.get_or_create(member=member)
        return profile, None

    def get(self, request):
        profile, err = self._get_or_create_profile(request)
        if err: return err
        return Response(ProgressProfileSerializer(profile).data)

    def put(self, request):
        profile, err = self._get_or_create_profile(request)
        if err: return err
        serializer = UpdateProgressProfileSerializer(
            profile, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(ProgressProfileSerializer(profile).data)
        return Response(serializer.errors,
                        status=status.HTTP_400_BAD_REQUEST)


class MemberWeightLogView(APIView):
    """Log weekly weight or get history"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            member = request.user.member
        except:
            return Response({'error': 'No member account'},
                            status=status.HTTP_403_FORBIDDEN)
        logs = WeightLog.objects.filter(member=member)
        return Response(WeightLogSerializer(logs, many=True).data)

    def post(self, request):
        try:
            member = request.user.member
        except:
            return Response({'error': 'No member account'},
                            status=status.HTTP_403_FORBIDDEN)
        serializer = CreateWeightLogSerializer(data=request.data)
        if serializer.is_valid():
            log = WeightLog.objects.create(
                member=member, **serializer.validated_data)
            # Update current weight in progress profile
            profile, _ = ProgressProfile.objects.get_or_create(
                member=member)
            profile.current_weight = log.weight
            profile.save()
            return Response(WeightLogSerializer(log).data,
                            status=status.HTTP_201_CREATED)
        return Response(serializer.errors,
                        status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        try:
            member = request.user.member
            log    = WeightLog.objects.get(pk=pk, member=member)
            log.delete()
            return Response({'message': 'Deleted'},
                            status=status.HTTP_204_NO_CONTENT)
        except WeightLog.DoesNotExist:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)