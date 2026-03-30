from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .models import MealPlan

from .models import MealPlan, GymSettings, Payment
from .serializers import (
    MealPlanSerializer, MealPlanCreateSerializer,
    GymSettingsSerializer,
    PaymentSerializer, CreatePaymentSerializer,
)
from django.db.models import Sum
from django.utils import timezone
from datetime import timedelta


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



class GymSettingsView(APIView):
    """Get or update gym settings"""

    def get_permissions(self):
        if self.request.method == 'GET':
            return [IsAuthenticated()]
        return [IsAuthenticated(), IsAdminUser()]

    def get(self, request):
        settings = GymSettings.get_settings()
        return Response(GymSettingsSerializer(settings).data)

    def put(self, request):
        settings = GymSettings.get_settings()
        serializer = GymSettingsSerializer(
            settings, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors,
                        status=status.HTTP_400_BAD_REQUEST)


class PaymentListCreateView(APIView):
    """Admin lists or records payments"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        payments = Payment.objects.select_related(
            'member__user', 'recorded_by').all()
        return Response(PaymentSerializer(payments, many=True).data)

    def post(self, request):
        serializer = CreatePaymentSerializer(
            data=request.data,
            context={'admin_user': request.user},
        )
        if serializer.is_valid():
            payment = serializer.save()
            return Response(
                PaymentSerializer(payment).data,
                status=status.HTTP_201_CREATED,
            )
        return Response(serializer.errors,
                        status=status.HTTP_400_BAD_REQUEST)


class PaymentStatsView(APIView):
    """Revenue stats for financial dashboard"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get(self, request):
        now       = timezone.now()
        # This month
        month_start = now.replace(day=1, hour=0, minute=0,
                                   second=0, microsecond=0)
        monthly_payments = Payment.objects.filter(
            paid_at__gte=month_start)
        monthly_revenue  = monthly_payments.aggregate(
            total=Sum('amount'))['total'] or 0

        # Last month
        last_month_end   = month_start - timedelta(days=1)
        last_month_start = last_month_end.replace(day=1)
        last_revenue     = Payment.objects.filter(
            paid_at__gte=last_month_start,
            paid_at__lt=month_start,
        ).aggregate(total=Sum('amount'))['total'] or 0

        # Revenue by plan this month
        by_plan = {}
        for plan in ['basic', 'standard', 'premium']:
            by_plan[plan] = monthly_payments.filter(
                plan=plan
            ).aggregate(total=Sum('amount'))['total'] or 0

        # Expiring soon (next 30 days)
        from apps.accounts.models import Member
        expiring = Member.objects.filter(
            expiry_date__gte=now.date(),
            expiry_date__lte=(now + timedelta(days=30)).date(),
            status='active',
        ).select_related('user').order_by('expiry_date')[:10]

        from apps.accounts.serializers import MemberSerializer
        expiring_data = MemberSerializer(expiring, many=True).data

        # Recent payments (last 5)
        recent = Payment.objects.select_related(
            'member__user').all()[:5]
        recent_data = PaymentSerializer(recent, many=True).data

        # Monthly trend (last 6 months)
        trend = []
        for i in range(5, -1, -1):
            m_start = (now - timedelta(days=30 * i)).replace(
                day=1, hour=0, minute=0, second=0, microsecond=0)
            m_end   = (m_start + timedelta(days=32)).replace(day=1)
            rev     = Payment.objects.filter(
                paid_at__gte=m_start,
                paid_at__lt=m_end,
            ).aggregate(total=Sum('amount'))['total'] or 0
            trend.append({
                'month':   m_start.strftime('%b'),
                'revenue': rev,
            })

        return Response({
            'monthly_revenue':   monthly_revenue,
            'last_month_revenue': last_revenue,
            'revenue_by_plan':   by_plan,
            'expiring_soon':     expiring_data,
            'recent_payments':   recent_data,
            'monthly_trend':     trend,
            'total_payments':    Payment.objects.count(),
        })


class PaymentDeleteView(APIView):
    """Admin deletes a payment"""
    permission_classes = [IsAuthenticated, IsAdminUser]

    def delete(self, request, pk):
        try:
            payment = Payment.objects.get(pk=pk)
            payment.delete()
            return Response({'message': 'Deleted'},
                            status=status.HTTP_204_NO_CONTENT)
        except Payment.DoesNotExist:
            return Response({'error': 'Not found'},
                            status=status.HTTP_404_NOT_FOUND)