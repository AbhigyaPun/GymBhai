from rest_framework import serializers
from .models import MealPlan, Meal, FoodItem


class FoodItemSerializer(serializers.ModelSerializer):
    class Meta:
        model  = FoodItem
        fields = ['id', 'order', 'name', 'quantity',
                  'calories', 'protein', 'carbs', 'fat', 'notes']


class MealSerializer(serializers.ModelSerializer):
    food_items = FoodItemSerializer(many=True, read_only=True)
    total_calories = serializers.SerializerMethodField()

    class Meta:
        model  = Meal
        fields = ['id', 'name', 'order', 'notes', 'food_items', 'total_calories']

    def get_total_calories(self, obj):
        return sum(f.calories for f in obj.food_items.all())


class MealPlanSerializer(serializers.ModelSerializer):
    meals      = MealSerializer(many=True, read_only=True)
    meal_count = serializers.SerializerMethodField()
    food_count = serializers.SerializerMethodField()

    class Meta:
        model  = MealPlan
        fields = ['id', 'name', 'description', 'goal', 'diet_type',
                  'total_calories', 'is_active', 'created_at',
                  'meal_count', 'food_count', 'meals']

    def get_meal_count(self, obj):
        return obj.meals.count()

    def get_food_count(self, obj):
        return sum(meal.food_items.count() for meal in obj.meals.all())


class FoodItemCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model  = FoodItem
        fields = ['order', 'name', 'quantity', 'calories',
                  'protein', 'carbs', 'fat', 'notes']


class MealCreateSerializer(serializers.ModelSerializer):
    food_items = FoodItemCreateSerializer(many=True, required=False)

    class Meta:
        model  = Meal
        fields = ['name', 'order', 'notes', 'food_items']


class MealPlanCreateSerializer(serializers.ModelSerializer):
    meals = MealCreateSerializer(many=True, required=False)

    class Meta:
        model  = MealPlan
        fields = ['name', 'description', 'goal', 'diet_type',
                  'total_calories', 'meals']

    def create(self, validated_data):
        meals_data = validated_data.pop('meals', [])
        plan       = MealPlan.objects.create(**validated_data)
        for i, meal_data in enumerate(meals_data):
            food_items_data = meal_data.pop('food_items', [])
            meal = Meal.objects.create(plan=plan, **meal_data)
            for j, food_data in enumerate(food_items_data):
                if 'order' not in food_data:
                    food_data['order'] = j + 1
                FoodItem.objects.create(meal=meal, **food_data)
        return plan

    def update(self, instance, validated_data):
        meals_data = validated_data.pop('meals', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if meals_data is not None:
            instance.meals.all().delete()
            for meal_data in meals_data:
                food_items_data = meal_data.pop('food_items', [])
                meal = Meal.objects.create(plan=instance, **meal_data)
                for j, food_data in enumerate(food_items_data):
                    if 'order' not in food_data:
                        food_data['order'] = j + 1
                    FoodItem.objects.create(meal=meal, **food_data)
        return instance