from django.db import models


class MealPlan(models.Model):
    GOAL_CHOICES = [
        ('bulk', 'Bulk'), ('cut', 'Cut'),
        ('maintain', 'Maintain'),
    ]
    DIET_CHOICES = [
        ('vegetarian', 'Vegetarian'),
        ('non_vegetarian', 'Non-Vegetarian'),
        ('vegan', 'Vegan'),
    ]

    name        = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    goal        = models.CharField(max_length=20, choices=GOAL_CHOICES, default='maintain')
    diet_type   = models.CharField(max_length=20, choices=DIET_CHOICES, default='vegetarian')
    total_calories = models.PositiveIntegerField(default=0)
    is_active   = models.BooleanField(default=True)
    created_at  = models.DateTimeField(auto_now_add=True)
    updated_at  = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} ({self.goal})"


class Meal(models.Model):
    MEAL_CHOICES = [
        ('breakfast', 'Breakfast'),
        ('lunch', 'Lunch'),
        ('snacks', 'Snacks'),
        ('dinner', 'Dinner'),
        ('pre_workout', 'Pre Workout'),
        ('post_workout', 'Post Workout'),
    ]

    plan       = models.ForeignKey(MealPlan, on_delete=models.CASCADE, related_name='meals')
    name       = models.CharField(max_length=50, choices=MEAL_CHOICES, default='breakfast')
    order      = models.PositiveIntegerField(default=1)
    notes      = models.TextField(blank=True)

    class Meta:
        ordering = ['order']
        unique_together = ['plan', 'name']

    def __str__(self):
        return f"{self.plan.name} - {self.name}"


class FoodItem(models.Model):
    meal        = models.ForeignKey(Meal, on_delete=models.CASCADE, related_name='food_items')
    order       = models.PositiveIntegerField(default=1)
    name        = models.CharField(max_length=100)
    quantity    = models.CharField(max_length=100)
    calories    = models.PositiveIntegerField(default=0)
    protein     = models.DecimalField(max_digits=6, decimal_places=1, default=0)
    carbs       = models.DecimalField(max_digits=6, decimal_places=1, default=0)
    fat         = models.DecimalField(max_digits=6, decimal_places=1, default=0)
    notes       = models.TextField(blank=True)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"{self.name} ({self.quantity})"

class GymSettings(models.Model):
    """Single row — gym configuration"""
    gym_name         = models.CharField(max_length=100,
                                        default='Gym Bhai')
    basic_price      = models.PositiveIntegerField(default=2800)
    standard_price   = models.PositiveIntegerField(default=4800)
    premium_price    = models.PositiveIntegerField(default=8500)
    basic_duration   = models.PositiveIntegerField(default=1)
    standard_duration = models.PositiveIntegerField(default=1)
    premium_duration = models.PositiveIntegerField(default=1)
    currency         = models.CharField(max_length=10, default='Rs')
    updated_at       = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name        = 'Gym Settings'
        verbose_name_plural = 'Gym Settings'

    def __str__(self):
        return self.gym_name

    @classmethod
    def get_settings(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj


class Payment(models.Model):
    PLAN_CHOICES = [
        ('basic', 'Basic'),
        ('standard', 'Standard'),
        ('premium', 'Premium'),
    ]
    DURATION_CHOICES = [
        (1, '1 Month'),
        (3, '3 Months'),
        (6, '6 Months'),
        (12, '12 Months'),
    ]
    METHOD_CHOICES = [
        ('cash', 'Cash'),
        ('transfer', 'Bank Transfer'),
        ('esewa', 'eSewa'),
        ('khalti', 'Khalti'),
        ('other', 'Other'),
    ]

    member         = models.ForeignKey('accounts.Member',
                                        on_delete=models.CASCADE,
                                        related_name='payments')
    plan           = models.CharField(max_length=20, choices=PLAN_CHOICES)
    amount         = models.PositiveIntegerField()
    duration_months = models.PositiveIntegerField(
                          choices=DURATION_CHOICES, default=1)
    payment_method = models.CharField(max_length=20,
                                       choices=METHOD_CHOICES,
                                       default='cash')
    notes          = models.TextField(blank=True)
    paid_at        = models.DateTimeField(auto_now_add=True)
    recorded_by    = models.ForeignKey('auth.User',
                                        on_delete=models.SET_NULL,
                                        null=True)

    class Meta:
        ordering = ['-paid_at']

    def __str__(self):
        return f"{self.member} - Rs {self.amount} ({self.plan})"