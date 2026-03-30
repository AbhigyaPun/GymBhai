from django.urls import path
from .views import (
    AdminMealPlanListCreateView,
    AdminMealPlanDetailView,
    MemberMealPlanListView,
    MemberMealPlanDetailView,
    GymSettingsView,
    PaymentListCreateView,
    PaymentStatsView,
    PaymentDeleteView,
)

urlpatterns = [
    # Meal plans - Admin
    path('admin/meal-plans/',
         AdminMealPlanListCreateView.as_view()),
    path('admin/meal-plans/<int:pk>/',
         AdminMealPlanDetailView.as_view()),

    # Meal plans - Member
    path('meal-plans/',
         MemberMealPlanListView.as_view()),
    path('meal-plans/<int:pk>/',
         MemberMealPlanDetailView.as_view()),

    # Settings
    path('settings/',
         GymSettingsView.as_view(), name='gym-settings'),

    # Payments
    path('payments/',
         PaymentListCreateView.as_view(), name='payments'),
    path('payments/stats/',
         PaymentStatsView.as_view(), name='payment-stats'),
    path('payments/<int:pk>/',
         PaymentDeleteView.as_view(), name='payment-delete'),
]