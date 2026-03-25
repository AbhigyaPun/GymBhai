from django.db import models
from apps.accounts.models import Member


class WorkoutSplit(models.Model):
    GOAL_CHOICES = [
        ('bulk', 'Bulk'), ('cut', 'Cut'),
        ('maintain', 'Maintain'), ('strength', 'Strength'),
    ]
    LEVEL_CHOICES = [
        ('beginner', 'Beginner'),
        ('intermediate', 'Intermediate'),
        ('advanced', 'Advanced'),
    ]
    name          = models.CharField(max_length=100)
    description   = models.TextField(blank=True)
    goal          = models.CharField(max_length=20, choices=GOAL_CHOICES, default='maintain')
    level         = models.CharField(max_length=20, choices=LEVEL_CHOICES, default='beginner')
    days_per_week = models.PositiveIntegerField(default=3)
    is_active     = models.BooleanField(default=True)
    created_at    = models.DateTimeField(auto_now_add=True)
    updated_at    = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} ({self.level})"


class WorkoutDay(models.Model):
    split      = models.ForeignKey(WorkoutSplit, on_delete=models.CASCADE, related_name='days')
    day_number = models.PositiveIntegerField()
    name       = models.CharField(max_length=100)
    notes      = models.TextField(blank=True)

    class Meta:
        ordering = ['day_number']
        unique_together = ['split', 'day_number']

    def __str__(self):
        return f"{self.split.name} - Day {self.day_number}: {self.name}"


class Exercise(models.Model):
    day         = models.ForeignKey(WorkoutDay, on_delete=models.CASCADE, related_name='exercises')
    order       = models.PositiveIntegerField(default=1)
    name        = models.CharField(max_length=100)
    sets        = models.PositiveIntegerField(default=3)
    reps        = models.CharField(max_length=50)
    weight_note = models.CharField(max_length=100, blank=True)
    notes       = models.TextField(blank=True)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"{self.name} - {self.sets}x{self.reps}"

class WorkoutLog(models.Model):
    member    = models.ForeignKey(Member, on_delete=models.CASCADE,
                                  related_name='workout_logs')
    day       = models.ForeignKey(WorkoutDay, on_delete=models.CASCADE,
                                  related_name='logs')
    logged_at = models.DateTimeField(auto_now_add=True)
    notes     = models.TextField(blank=True)

    class Meta:
        ordering = ['-logged_at']

    def __str__(self):
        return f"{self.member} - {self.day} - {self.logged_at.date()}"


class ExerciseLog(models.Model):
    workout_log = models.ForeignKey(WorkoutLog, on_delete=models.CASCADE,
                                    related_name='exercise_logs')
    exercise    = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    sets_done   = models.PositiveIntegerField(default=0)
    reps_done   = models.CharField(max_length=100, blank=True)
    weight_used = models.CharField(max_length=100, blank=True)
    notes       = models.TextField(blank=True)

    def __str__(self):
        return f"{self.exercise.name} - {self.sets_done} sets"