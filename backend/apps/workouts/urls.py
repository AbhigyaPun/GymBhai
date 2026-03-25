from django.urls import path
from .views import (
    WorkoutSplitListCreateView,
    WorkoutSplitDetailView,
    MemberWorkoutSplitListView,
    MemberWorkoutSplitDetailView,
    MemberWorkoutLogListCreateView,
    MemberWorkoutLogDetailView,
    AdminWorkoutLogListView,
)

urlpatterns = [
    # Admin splits
    path('admin/splits/',
         WorkoutSplitListCreateView.as_view(), name='admin-split-list'),
    path('admin/splits/<int:pk>/',
         WorkoutSplitDetailView.as_view(),     name='admin-split-detail'),

    # Admin logs
    path('admin/logs/',
         AdminWorkoutLogListView.as_view(), name='admin-log-list'),

    # Member splits
    path('splits/',
         MemberWorkoutSplitListView.as_view(),   name='member-split-list'),
    path('splits/<int:pk>/',
         MemberWorkoutSplitDetailView.as_view(), name='member-split-detail'),

    # Member logs
    path('logs/',
         MemberWorkoutLogListCreateView.as_view(), name='member-log-list'),
    path('logs/<int:pk>/',
         MemberWorkoutLogDetailView.as_view(),     name='member-log-detail'),
]