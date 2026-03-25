from rest_framework import serializers
from .models import WorkoutSplit, WorkoutDay, Exercise, WorkoutLog, ExerciseLog


class ExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Exercise
        fields = ['id', 'order', 'name', 'sets', 'reps', 'weight_note', 'notes']


class WorkoutDaySerializer(serializers.ModelSerializer):
    exercises = ExerciseSerializer(many=True, read_only=True)

    class Meta:
        model  = WorkoutDay
        fields = ['id', 'day_number', 'name', 'notes', 'exercises']


class WorkoutSplitSerializer(serializers.ModelSerializer):
    days           = WorkoutDaySerializer(many=True, read_only=True)
    day_count      = serializers.SerializerMethodField()
    exercise_count = serializers.SerializerMethodField()

    class Meta:
        model  = WorkoutSplit
        fields = ['id', 'name', 'description', 'goal', 'level',
                  'days_per_week', 'is_active', 'created_at',
                  'day_count', 'exercise_count', 'days']

    def get_day_count(self, obj):
        return obj.days.count()

    def get_exercise_count(self, obj):
        return sum(day.exercises.count() for day in obj.days.all())


class ExerciseCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Exercise
        fields = ['order', 'name', 'sets', 'reps', 'weight_note', 'notes']


class WorkoutDayCreateSerializer(serializers.ModelSerializer):
    exercises = ExerciseCreateSerializer(many=True, required=False)

    class Meta:
        model  = WorkoutDay
        fields = ['day_number', 'name', 'notes', 'exercises']


class WorkoutSplitCreateSerializer(serializers.ModelSerializer):
    days = WorkoutDayCreateSerializer(many=True, required=False)

    class Meta:
        model  = WorkoutSplit
        fields = ['name', 'description', 'goal', 'level', 'days_per_week', 'days']

    def create(self, validated_data):
        days_data = validated_data.pop('days', [])
        split     = WorkoutSplit.objects.create(**validated_data)
        for day_data in days_data:
            exercises_data = day_data.pop('exercises', [])
            day = WorkoutDay.objects.create(split=split, **day_data)
            for i, ex_data in enumerate(exercises_data):
                if 'order' not in ex_data:
                    ex_data['order'] = i + 1
                Exercise.objects.create(day=day, **ex_data)
        return split

    def update(self, instance, validated_data):
        days_data = validated_data.pop('days', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if days_data is not None:
            instance.days.all().delete()
            for day_data in days_data:
                exercises_data = day_data.pop('exercises', [])
                day = WorkoutDay.objects.create(split=instance, **day_data)
                for i, ex_data in enumerate(exercises_data):
                    if 'order' not in ex_data:
                        ex_data['order'] = i + 1
                    Exercise.objects.create(day=day, **ex_data)
        return instance

class ExerciseLogSerializer(serializers.ModelSerializer):
    exercise_name = serializers.CharField(
        source='exercise.name', read_only=True)
    exercise_sets = serializers.IntegerField(
        source='exercise.sets', read_only=True)
    exercise_reps = serializers.CharField(
        source='exercise.reps', read_only=True)

    class Meta:
        model  = ExerciseLog
        fields = ['id', 'exercise', 'exercise_name', 'exercise_sets',
                  'exercise_reps', 'sets_done', 'reps_done',
                  'weight_used', 'notes']


class WorkoutLogSerializer(serializers.ModelSerializer):
    day_name      = serializers.CharField(source='day.name', read_only=True)
    day_number    = serializers.IntegerField(
        source='day.day_number', read_only=True)
    split_name    = serializers.CharField(
        source='day.split.name', read_only=True)
    split_id      = serializers.IntegerField(
        source='day.split.id', read_only=True)
    exercise_logs = ExerciseLogSerializer(many=True, read_only=True)

    class Meta:
        model  = WorkoutLog
        fields = ['id', 'day', 'day_name', 'day_number', 'split_name',
                  'split_id', 'logged_at', 'notes', 'exercise_logs']


class CreateWorkoutLogSerializer(serializers.Serializer):
    day_id        = serializers.IntegerField()
    notes         = serializers.CharField(required=False,
                                          allow_blank=True, default='')
    exercise_logs = serializers.ListField(
        child=serializers.DictField(), required=False, default=list)

    def create(self, validated_data):
        from .models import WorkoutDay, WorkoutLog, ExerciseLog
        member = self.context['member']
        day    = WorkoutDay.objects.get(id=validated_data['day_id'])
        log    = WorkoutLog.objects.create(
            member=member,
            day=day,
            notes=validated_data.get('notes', ''),
        )
        for el in validated_data.get('exercise_logs', []):
            ExerciseLog.objects.create(
                workout_log = log,
                exercise_id = el.get('exercise_id'),
                sets_done   = el.get('sets_done', 0),
                reps_done   = el.get('reps_done', ''),
                weight_used = el.get('weight_used', ''),
                notes       = el.get('notes', ''),
            )
        return log