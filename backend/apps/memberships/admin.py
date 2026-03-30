from django.contrib import admin
from .models import MealPlan, Meal, FoodItem, GymSettings, Payment


class FoodItemInline(admin.TabularInline):
    model  = FoodItem
    extra  = 1
    fields = ['order', 'name', 'quantity', 'calories',
              'protein', 'carbs', 'fat']


class MealInline(admin.StackedInline):
    model  = Meal
    extra  = 1
    fields = ['name', 'order', 'notes']


@admin.register(MealPlan)
class MealPlanAdmin(admin.ModelAdmin):
    list_display  = ['name', 'goal', 'diet_type',
                     'total_calories', 'is_active', 'created_at']
    list_filter   = ['goal', 'diet_type', 'is_active']
    inlines       = [MealInline]


@admin.register(Meal)
class MealAdmin(admin.ModelAdmin):
    list_display = ['plan', 'name', 'order']
    inlines      = [FoodItemInline]




@admin.register(GymSettings)
class GymSettingsAdmin(admin.ModelAdmin):
    list_display = ['gym_name', 'basic_price',
                    'standard_price', 'premium_price']


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ['member', 'plan', 'amount',
                    'duration_months', 'payment_method', 'paid_at']
    list_filter  = ['plan', 'payment_method']