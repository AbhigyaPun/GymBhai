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
)

urlpatterns = [
    # Auth
    path('login/',         AdminLoginView.as_view(),       name='admin-login'),
    path('member/login/',  MemberLoginView.as_view(),      name='member-login'),

    # Members
    path('members/',          MemberListCreateView.as_view(), name='member-list-create'),
    path('members/<int:pk>/', MemberDetailView.as_view(),    name='member-detail'),

    # QR
    path('member/qr/',         MemberQRView.as_view(),         name='member-qr'),
    path('member/attendance/', MemberAttendanceView.as_view(), name='member-attendance'),

    # Profile
    path('member/profile/',    MemberProfileView.as_view(),    name='member-profile'),  # ADD THIS

    # Attendance
    path('attendance/scan/', AttendanceScanView.as_view(), name='attendance-scan'),
    path('attendance/',      AttendanceListView.as_view(), name='attendance-list'),

    # Feedback
    path('member/feedback/',         MemberFeedbackView.as_view(),      name='member-feedback'),
    path('admin/feedback/',          AdminFeedbackView.as_view(),       name='admin-feedback'),
    path('admin/feedback/<int:pk>/', AdminFeedbackDetailView.as_view(), name='admin-feedback-detail'),
]