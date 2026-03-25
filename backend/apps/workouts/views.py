from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .models import WorkoutSplit
from .models import WorkoutSplit, WorkoutLog
from .serializers import (
    WorkoutSplitSerializer,
    WorkoutSplitCreateSerializer,
    WorkoutLogSerializer,
    CreateWorkoutLogSerializer,
)

class WorkoutSplitListCreateView(APIView):
    """Admin: list all splits or create a new one"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        splits = WorkoutSplit.objects.prefetch_related('days__exercises').all()
        return Response(WorkoutSplitSerializer(splits, many=True).data)

    def post(self, request):
        serializer = WorkoutSplitCreateSerializer(data=request.data)
        if serializer.is_valid():
            split = serializer.save()
            return Response(WorkoutSplitSerializer(split).data,
                            status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class WorkoutSplitDetailView(APIView):
    """Admin: retrieve, update or delete a split"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get_object(self, pk):
        try:
            return WorkoutSplit.objects.prefetch_related('days__exercises').get(pk=pk)
        except WorkoutSplit.DoesNotExist:
            return None

    def get(self, request, pk):
        split = self.get_object(pk)
        if not split:
            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        return Response(WorkoutSplitSerializer(split).data)

    def put(self, request, pk):
        split = self.get_object(pk)
        if not split:
            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = WorkoutSplitCreateSerializer(split, data=request.data)
        if serializer.is_valid():
            split = serializer.save()
            return Response(WorkoutSplitSerializer(split).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        split = self.get_object(pk)
        if not split:
            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        split.delete()
        return Response({'message': 'Deleted'}, status=status.HTTP_204_NO_CONTENT)

    def patch(self, request, pk):
        """Toggle is_active"""
        split = self.get_object(pk)
        if not split:
            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        split.is_active = not split.is_active
        split.save()
        return Response(WorkoutSplitSerializer(split).data)


class MemberWorkoutSplitListView(APIView):
    """Members: see all active splits"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        splits = WorkoutSplit.objects.prefetch_related(
            'days__exercises'
        ).filter(is_active=True)
        return Response(WorkoutSplitSerializer(splits, many=True).data)


class MemberWorkoutSplitDetailView(APIView):
    """Members: see a single split with all days and exercises"""
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            split = WorkoutSplit.objects.prefetch_related(
                'days__exercises'
            ).get(pk=pk, is_active=True)
        except WorkoutSplit.DoesNotExist:
            return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
        return Response(WorkoutSplitSerializer(split).data)

class MemberWorkoutLogListCreateView(APIView):
    """Member logs a workout or views their history"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            member = request.user.member
        except:
            return Response({'error': 'No member account'},
                            status=status.HTTP_403_FORBIDDEN)
        logs = WorkoutLog.objects.filter(
            member=member
        ).select_related(
            'day__split'
        ).prefetch_related(
            'exercise_logs__exercise'
        )
        return Response(WorkoutLogSerializer(logs, many=True).data)

    def post(self, request):
        try:
            member = request.user.member
        except:
            return Response({'error': 'No member account'},
                            status=status.HTTP_403_FORBIDDEN)
        serializer = CreateWorkoutLogSerializer(
            data=request.data,
            context={'member': member},
        )
        if serializer.is_valid():
            log = serializer.save()
            return Response(
                WorkoutLogSerializer(log).data,
                status=status.HTTP_201_CREATED,
            )
        return Response(serializer.errors,
                        status=status.HTTP_400_BAD_REQUEST)


class MemberWorkoutLogDetailView(APIView):
    """Member deletes a log"""
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            member = request.user.member
            log    = WorkoutLog.objects.get(pk=pk, member=member)
            log.delete()
            return Response({'message': 'Deleted'},
                            status=status.HTTP_204_NO_CONTENT)
        except WorkoutLog.DoesNotExist:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)


class AdminWorkoutLogListView(APIView):
    """Admin sees all workout logs"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        logs = WorkoutLog.objects.select_related(
            'member__user', 'day__split'
        ).prefetch_related(
            'exercise_logs__exercise'
        ).all()[:200]
        return Response(WorkoutLogSerializer(logs, many=True).data)