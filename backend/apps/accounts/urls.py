from django.urls import path
from .views import AdminLoginView, MemberLoginView, MemberListCreateView, MemberDetailView

urlpatterns = [
    path('login/', AdminLoginView.as_view(), name='admin-login'),
    path('member/login/', MemberLoginView.as_view(), name='member-login'),
    path('members/', MemberListCreateView.as_view(), name='member-list-create'),
    path('members/<int:pk>/', MemberDetailView.as_view(), name='member-detail'),
]