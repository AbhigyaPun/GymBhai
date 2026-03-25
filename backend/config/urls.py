from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('apps.accounts.urls')),
    path('api/workouts/', include('apps.workouts.urls')),
    path('api/meals/', include('apps.memberships.urls')),
    path('api/progress/', include('apps.progress.urls')),  
    path('api/token/refresh/', TokenRefreshView.as_view()),
]