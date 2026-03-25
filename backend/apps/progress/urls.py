from django.urls import path
from .views import MemberProgressView, MemberWeightLogView

urlpatterns = [
    path('profile/',      MemberProgressView.as_view(),  name='progress-profile'),
    path('logs/',         MemberWeightLogView.as_view(),  name='weight-logs'),
    path('logs/<int:pk>/', MemberWeightLogView.as_view(), name='weight-log-delete'),
]