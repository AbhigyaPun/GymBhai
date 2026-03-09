from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Member, Attendance


class MemberSerializer(serializers.ModelSerializer):
    first_name = serializers.CharField(source='user.first_name')
    last_name  = serializers.CharField(source='user.last_name', required=False, allow_blank=True)
    email      = serializers.EmailField(source='user.email')
    username   = serializers.CharField(source='user.username', read_only=True)
    checkins   = serializers.SerializerMethodField()

    class Meta:
        model  = Member
        fields = [
            'id', 'first_name', 'last_name', 'email', 'username',
            'phone', 'goal', 'membership', 'status',
            'member_since', 'expiry_date', 'checkins',
        ]

    def get_checkins(self, obj):
        return obj.attendances.count()


class AttendanceSerializer(serializers.ModelSerializer):
    member_name = serializers.SerializerMethodField()
    member_id   = serializers.IntegerField(source='member.id')
    membership  = serializers.CharField(source='member.membership')

    class Meta:
        model  = Attendance
        fields = ['id', 'member_id', 'member_name', 'membership', 'checked_in']

    def get_member_name(self, obj):
        return obj.member.user.get_full_name() or obj.member.user.username


class CreateMemberSerializer(serializers.Serializer):
    first_name  = serializers.CharField()
    last_name   = serializers.CharField(required=False, allow_blank=True, default='')
    email       = serializers.EmailField()
    phone       = serializers.CharField(required=False, allow_blank=True, default='')
    password    = serializers.CharField(write_only=True, min_length=6)
    goal        = serializers.ChoiceField(choices=['bulk', 'cut', 'maintain'], default='maintain')
    membership  = serializers.ChoiceField(choices=['basic', 'standard', 'premium'], default='basic')
    expiry_date = serializers.DateField(required=False, allow_null=True)

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A member with this email already exists.")
        return value

    def create(self, validated_data):
        username = validated_data['email'].split('@')[0]
        base_username = username
        counter = 1
        while User.objects.filter(username=username).exists():
            username = f"{base_username}{counter}"
            counter += 1

        user = User.objects.create_user(
            username=username,
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data['first_name'],
            last_name=validated_data.get('last_name', ''),
        )
        member = Member.objects.create(
            user=user,
            phone=validated_data.get('phone', ''),
            goal=validated_data.get('goal', 'maintain'),
            membership=validated_data.get('membership', 'basic'),
            expiry_date=validated_data.get('expiry_date'),
        )
        return member


class UpdateMemberSerializer(serializers.Serializer):
    first_name  = serializers.CharField(required=False)
    last_name   = serializers.CharField(required=False, allow_blank=True)
    email       = serializers.EmailField(required=False)
    phone       = serializers.CharField(required=False, allow_blank=True)
    password    = serializers.CharField(required=False, write_only=True, min_length=6)
    goal        = serializers.ChoiceField(choices=['bulk', 'cut', 'maintain'], required=False)
    membership  = serializers.ChoiceField(choices=['basic', 'standard', 'premium'], required=False)
    status      = serializers.ChoiceField(choices=['active', 'frozen', 'expired'], required=False)
    expiry_date = serializers.DateField(required=False, allow_null=True)

    def validate_email(self, value):
        member = self.context.get('member')
        if User.objects.filter(email=value).exclude(pk=member.user.pk).exists():
            raise serializers.ValidationError("A member with this email already exists.")
        return value

    def update(self, instance, validated_data):
        user = instance.user
        if 'first_name'  in validated_data: user.first_name = validated_data['first_name']
        if 'last_name'   in validated_data: user.last_name  = validated_data['last_name']
        if 'email'       in validated_data: user.email      = validated_data['email']
        if 'password'    in validated_data: user.set_password(validated_data['password'])
        user.save()

        if 'phone'       in validated_data: instance.phone       = validated_data['phone']
        if 'goal'        in validated_data: instance.goal        = validated_data['goal']
        if 'membership'  in validated_data: instance.membership  = validated_data['membership']
        if 'status'      in validated_data: instance.status      = validated_data['status']
        if 'expiry_date' in validated_data: instance.expiry_date = validated_data['expiry_date']
        instance.save()
        return instance


class AdminLoginSerializer(serializers.Serializer):
    email    = serializers.EmailField()
    password = serializers.CharField()