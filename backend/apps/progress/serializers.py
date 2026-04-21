from rest_framework import serializers
from .models import ProgressProfile, WeightLog


class WeightLogSerializer(serializers.ModelSerializer):
    class Meta:
        model  = WeightLog
        fields = ['id', 'weight', 'notes', 'logged_at']


class ProgressProfileSerializer(serializers.ModelSerializer):
    weight_logs            = serializers.SerializerMethodField()
    recommended_target     = serializers.SerializerMethodField()
    progress_percentage    = serializers.SerializerMethodField()
    weight_to_goal         = serializers.SerializerMethodField()

    class Meta:
        model  = ProgressProfile
        fields = ['id', 'current_weight', 'target_weight', 'height',
                  'recommended_target', 'progress_percentage',
                  'weight_to_goal', 'weight_logs']

    def get_weight_logs(self, obj):
        logs = obj.member.weight_logs.all()[:12]
        return WeightLogSerializer(logs, many=True).data

    def get_recommended_target(self, obj):
        if not obj.current_weight:
            return None
        logs = obj.member.weight_logs.all()
        w = float(logs.first().weight) if logs.exists() else float(obj.current_weight)
        goal = obj.member.goal
        if goal == 'bulk':
            return round(w * 1.10, 1)
        elif goal == 'cut':
            return round(w * 0.90, 1)
        return round(w, 1)

    def get_progress_percentage(self, obj):
        if not obj.current_weight or not obj.target_weight:
            return 0
        target = float(obj.target_weight)
        logs = obj.member.weight_logs.all()
        if logs.count() >= 2:
            start   = float(logs.last().weight)
            current = float(logs.first().weight)
        elif logs.count() == 1:
            start   = float(obj.current_weight)
            current = float(logs.first().weight)
        else:
            return 0
        if start == target:
            return 100
        total_needed = abs(target - start)
        if total_needed == 0:
            return 100
        going_right_direction = (
            (target > start and current >= start) or
            (target < start and current <= start)
        )
        if not going_right_direction:
            return 0
        progress = (abs(current - start) / total_needed) * 100
        return min(round(progress, 1), 100)

    def get_weight_to_goal(self, obj):
        if not obj.target_weight:
            return None
        logs = obj.member.weight_logs.all()
        if logs.exists():
            current = float(logs.first().weight)
        elif obj.current_weight:
            current = float(obj.current_weight)
        else:
            return None
        return round(abs(float(obj.target_weight) - current), 1)


class UpdateProgressProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model  = ProgressProfile
        fields = ['current_weight', 'target_weight', 'height']


class CreateWeightLogSerializer(serializers.ModelSerializer):
    class Meta:
        model  = WeightLog
        fields = ['weight', 'notes']