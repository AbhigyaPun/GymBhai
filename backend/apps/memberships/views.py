from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .models import MealPlan
from .serializers import MealPlanSerializer, MealPlanCreateSerializer


class AdminMealPlanListCreateView(APIView):
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        plans = MealPlan.objects.prefetch_related('meals__food_items').all()
        return Response(MealPlanSerializer(plans, many=True).data)

    def post(self, request):
        serializer = MealPlanCreateSerializer(data=request.data)
        if serializer.is_valid():
            plan = serializer.save()
            return Response(MealPlanSerializer(plan).data,
                            status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class AdminMealPlanDetailView(APIView):
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get_object(self, pk):
        try:
            return MealPlan.objects.prefetch_related(
                'meals__food_items').get(pk=pk)
        except MealPlan.DoesNotExist:
            return None

    def get(self, request, pk):
        plan = self.get_object(pk)
        if not plan:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)
        return Response(MealPlanSerializer(plan).data)

    def put(self, request, pk):
        plan = self.get_object(pk)
        if not plan:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)
        serializer = MealPlanCreateSerializer(plan, data=request.data)
        if serializer.is_valid():
            plan = serializer.save()
            return Response(MealPlanSerializer(plan).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        plan = self.get_object(pk)
        if not plan:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)
        plan.delete()
        return Response({'message': 'Deleted'},
                        status=status.HTTP_204_NO_CONTENT)

    def patch(self, request, pk):
        plan = self.get_object(pk)
        if not plan:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)
        plan.is_active = not plan.is_active
        plan.save()
        return Response(MealPlanSerializer(plan).data)


class MemberMealPlanListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        plans = MealPlan.objects.prefetch_related(
            'meals__food_items').filter(is_active=True)
        return Response(MealPlanSerializer(plans, many=True).data)


class MemberMealPlanDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        try:
            plan = MealPlan.objects.prefetch_related(
                'meals__food_items').get(pk=pk, is_active=True)
        except MealPlan.DoesNotExist:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)
        return Response(MealPlanSerializer(plan).data)