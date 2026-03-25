from django.db import models
from apps.accounts.models import Member


class ProgressProfile(models.Model):
    """Stores member's weight goals — one per member"""
    member         = models.OneToOneField(Member, on_delete=models.CASCADE,
                                          related_name='progress_profile')
    current_weight = models.DecimalField(max_digits=5, decimal_places=1,
                                         null=True, blank=True)
    target_weight  = models.DecimalField(max_digits=5, decimal_places=1,
                                         null=True, blank=True)
    height         = models.DecimalField(max_digits=5, decimal_places=1,
                                         null=True, blank=True)
    created_at     = models.DateTimeField(auto_now_add=True)
    updated_at     = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.member} - {self.current_weight}kg → {self.target_weight}kg"


class WeightLog(models.Model):
    """Weekly weight check-in"""
    member    = models.ForeignKey(Member, on_delete=models.CASCADE,
                                  related_name='weight_logs')
    weight    = models.DecimalField(max_digits=5, decimal_places=1)
    notes     = models.TextField(blank=True)
    logged_at = models.DateField(auto_now_add=True)

    class Meta:
        ordering = ['-logged_at']

    def __str__(self):
        return f"{self.member} - {self.weight}kg on {self.logged_at}"