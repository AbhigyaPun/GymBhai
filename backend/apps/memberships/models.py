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