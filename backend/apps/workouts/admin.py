from django.contrib import admin
from .models import WorkoutSplit, WorkoutDay, Exercise, WorkoutLog, ExerciseLog



class ExerciseInline(admin.TabularInline):
    model  = Exercise
    extra  = 1
    fields = ['order', 'name', 'sets', 'reps', 'weight_note', 'notes']


class WorkoutDayInline(admin.StackedInline):
    model  = WorkoutDay
    extra  = 1
    fields = ['day_number', 'name', 'notes']


@admin.register(WorkoutSplit)
class WorkoutSplitAdmin(admin.ModelAdmin):
    list_display  = ['name', 'goal', 'level', 'days_per_week', 'is_active', 'created_at']
    list_filter   = ['goal', 'level', 'is_active']
    inlines       = [WorkoutDayInline]


@admin.register(WorkoutDay)
class WorkoutDayAdmin(admin.ModelAdmin):
    list_display = ['split', 'day_number', 'name']
    inlines      = [ExerciseInline]

class ExerciseLogInline(admin.TabularInline):
    model  = ExerciseLog
    extra  = 0
    fields = ['exercise', 'sets_done', 'reps_done', 'weight_used']


@admin.register(WorkoutLog)
class WorkoutLogAdmin(admin.ModelAdmin):
    list_display = ['member', 'day', 'logged_at']
    inlines      = [ExerciseLogInline]