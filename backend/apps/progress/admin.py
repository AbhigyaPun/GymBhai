from django.contrib import admin
from .models import ProgressProfile, WeightLog


@admin.register(ProgressProfile)
class ProgressProfileAdmin(admin.ModelAdmin):
    list_display = ['member', 'current_weight', 'target_weight', 'height']


@admin.register(WeightLog)
class WeightLogAdmin(admin.ModelAdmin):
    list_display = ['member', 'weight', 'logged_at']