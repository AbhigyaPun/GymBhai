import uuid
from django.db import models
from django.contrib.auth.models import User


class Member(models.Model):
    GOAL_CHOICES = [
        ('bulk', 'Bulk'),
        ('cut', 'Cut'),
        ('maintain', 'Maintain'),
    ]
    MEMBERSHIP_CHOICES = [
        ('basic', 'Basic'),
        ('standard', 'Standard'),
        ('premium', 'Premium'),
    ]
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('frozen', 'Frozen'),
        ('expired', 'Expired'),
    ]

    user       = models.OneToOneField(User, on_delete=models.CASCADE, related_name='member')
    phone      = models.CharField(max_length=20, blank=True)
    goal       = models.CharField(max_length=20, choices=GOAL_CHOICES, default='maintain')
    membership = models.CharField(max_length=20, choices=MEMBERSHIP_CHOICES, default='basic')
    status     = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    member_since = models.DateField(auto_now_add=True)
    expiry_date  = models.DateField(null=True, blank=True)
    # QR token — generated once, never changes
    qr_token   = models.CharField(max_length=64, unique=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        # Auto-generate qr_token on first save
        if not self.qr_token:
            self.qr_token = uuid.uuid4().hex  # 32-char random hex
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user.get_full_name()} ({self.user.email})"


class Attendance(models.Model):
    member     = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='attendances')
    checked_in = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-checked_in']

    def __str__(self):
        return f"{self.member} — {self.checked_in.strftime('%Y-%m-%d %H:%M')}"