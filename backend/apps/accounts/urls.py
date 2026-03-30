from django.urls import path
from .views import (
    AdminLoginView, MemberLoginView,
    MemberListCreateView, MemberDetailView,
    MemberQRView,
    AttendanceScanView, AttendanceListView,
    MemberAttendanceView,
    MemberFeedbackView,
    AdminFeedbackView,
    AdminFeedbackDetailView,
    MemberProfileView,
    AdminDashboardStatsView,  
)

urlpatterns = [
    # Auth
    path('login/',        AdminLoginView.as_view(),  name='admin-login'),
    path('member/login/', MemberLoginView.as_view(), name='member-login'),

    # Members
    path('members/',          MemberListCreateView.as_view()),
    path('members/<int:pk>/', MemberDetailView.as_view()),

    # QR
    path('member/qr/',         MemberQRView.as_view()),
    path('member/attendance/', MemberAttendanceView.as_view()),

    # Profile
    path('member/profile/', MemberProfileView.as_view()),

    # Attendance
    path('attendance/scan/', AttendanceScanView.as_view()),
    path('attendance/',      AttendanceListView.as_view()),

    # Feedback
    path('member/feedback/',         MemberFeedbackView.as_view()),
    path('admin/feedback/',          AdminFeedbackView.as_view()),
    path('admin/feedback/<int:pk>/', AdminFeedbackDetailView.as_view()),

    # Dashboard
    path('dashboard/stats/', AdminDashboardStatsView.as_view()),  
]