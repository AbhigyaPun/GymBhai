from django.urls import path
from .views import (
    AdminLoginView, MemberLoginView,
    MemberListCreateView, MemberDetailView,
    MemberQRView,
    AttendanceScanView, AttendanceListView,
    MemberAttendanceView,
)

urlpatterns = [
    # Auth
    path('login/',         AdminLoginView.as_view(),       name='admin-login'),
    path('member/login/',  MemberLoginView.as_view(),      name='member-login'),

    # Members
    path('members/',       MemberListCreateView.as_view(), name='member-list-create'),
    path('members/<int:pk>/', MemberDetailView.as_view(), name='member-detail'),

    # QR
    path('member/qr/',          MemberQRView.as_view(),          name='member-qr'),
    path('member/attendance/',  MemberAttendanceView.as_view(),  name='member-attendance'),

    # Attendance
    path('attendance/scan/',  AttendanceScanView.as_view(),  name='attendance-scan'),
    path('attendance/',       AttendanceListView.as_view(),  name='attendance-list'),
]