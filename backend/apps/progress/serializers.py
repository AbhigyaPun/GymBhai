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
        goal = obj.member.goal
        w    = float(obj.current_weight)
        if goal == 'bulk':
            return round(w * 1.10, 1)
        elif goal == 'cut':
            return round(w * 0.90, 1)
        else:
            return round(w, 1)

    def get_progress_percentage(self, obj):
        if not obj.current_weight or not obj.target_weight:
            return 0
        logs = obj.member.weight_logs.all()
        if not logs:
            return 0
        start  = float(logs.last().weight)
        target = float(obj.target_weight)
        current = float(logs.first().weight)
        if start == target:
            return 100
        progress = abs(current - start) / abs(target - start) * 100
        return min(round(progress, 1), 100)

    def get_weight_to_goal(self, obj):
        if not obj.target_weight:
            return None
        logs = obj.member.weight_logs.all()
        if not logs:
            if not obj.current_weight:
                return None
            return round(abs(float(obj.target_weight) -
                             float(obj.current_weight)), 1)
        current = float(logs.first().weight)
        return round(abs(float(obj.target_weight) - current), 1)


class UpdateProgressProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model  = ProgressProfile
        fields = ['current_weight', 'target_weight', 'height']


class CreateWeightLogSerializer(serializers.ModelSerializer):
    class Meta:
        model  = WeightLog
        fields = ['weight', 'notes']