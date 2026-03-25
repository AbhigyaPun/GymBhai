from django.urls import path
from .views import (
    AdminMealPlanListCreateView,
    AdminMealPlanDetailView,
    MemberMealPlanListView,
    MemberMealPlanDetailView,
)

urlpatterns = [
    # Admin
    path('admin/meal-plans/',
         AdminMealPlanListCreateView.as_view(), name='admin-meal-plan-list'),
    path('admin/meal-plans/<int:pk>/',
         AdminMealPlanDetailView.as_view(), name='admin-meal-plan-detail'),

    # Member (Flutter)
    path('meal-plans/',
         MemberMealPlanListView.as_view(), name='member-meal-plan-list'),
    path('meal-plans/<int:pk>/',
         MemberMealPlanDetailView.as_view(), name='member-meal-plan-detail'),
]