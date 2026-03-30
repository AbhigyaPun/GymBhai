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
    
from .models import MealPlan, Meal, FoodItem, GymSettings, Payment
from apps.accounts.models import Member
from apps.accounts.serializers import MemberSerializer


class GymSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model  = GymSettings
        fields = ['id', 'gym_name', 'basic_price', 'standard_price',
                  'premium_price', 'basic_duration', 'standard_duration',
                  'premium_duration', 'currency', 'updated_at']


class PaymentSerializer(serializers.ModelSerializer):
    member_name  = serializers.SerializerMethodField()
    membership   = serializers.CharField(
                       source='member.membership', read_only=True)
    recorded_by_name = serializers.SerializerMethodField()

    class Meta:
        model  = Payment
        fields = ['id', 'member', 'member_name', 'membership',
                  'plan', 'amount', 'duration_months',
                  'payment_method', 'notes', 'paid_at',
                  'recorded_by_name']

    def get_member_name(self, obj):
        return obj.member.user.get_full_name() or \
               obj.member.user.username

    def get_recorded_by_name(self, obj):
        if obj.recorded_by:
            return obj.recorded_by.get_full_name() or \
                   obj.recorded_by.username
        return '—'


class CreatePaymentSerializer(serializers.Serializer):
    member_id       = serializers.IntegerField()
    plan            = serializers.ChoiceField(
                          choices=['basic', 'standard', 'premium'])
    amount          = serializers.IntegerField(min_value=0)
    duration_months = serializers.ChoiceField(
                          choices=[1, 3, 6, 12])
    payment_method  = serializers.ChoiceField(
                          choices=['cash', 'transfer',
                                   'esewa', 'khalti', 'other'],
                          default='cash')
    notes           = serializers.CharField(required=False,
                                            allow_blank=True,
                                            default='')

    def create(self, validated_data):
        from django.utils import timezone
        from dateutil.relativedelta import relativedelta

        member = Member.objects.get(id=validated_data['member_id'])
        payment = Payment.objects.create(
            member         = member,
            plan           = validated_data['plan'],
            amount         = validated_data['amount'],
            duration_months = validated_data['duration_months'],
            payment_method = validated_data['payment_method'],
            notes          = validated_data.get('notes', ''),
            recorded_by    = self.context.get('admin_user'),
        )
        # Update member membership plan
        member.membership = validated_data['plan']
        member.status     = 'active'

        # Extend expiry date
        now = timezone.now().date()
        if member.expiry_date and member.expiry_date > now:
            base = member.expiry_date
        else:
            base = now
        member.expiry_date = base + relativedelta(
            months=validated_data['duration_months'])
        member.save()

        return payment