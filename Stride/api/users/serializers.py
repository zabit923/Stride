from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password


User = get_user_model()


class UserCreateSerializer(serializers.ModelSerializer):
    """
    Сериализатор пользователя.
    """
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_again = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email',
            'first_name', 'last_name', 'is_coach',
            'password', 'password_again',
        ]

    def validate(self, attrs):
        if attrs['password'] != attrs['password_again']:
            raise serializers.ValidationError({'password': 'Пароли не совпадают'})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_again')
        user = User.objects.create(
            is_coach=validated_data['is_coach'],
            username=validated_data['username'],
            email=validated_data['email'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],

        )
        user.set_password(validated_data['password'])
        user.save()
        return user


class UserGetSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email',
            'height', 'weight',
            'first_name', 'last_name', 'date_of_birth',
            'image', 'desc', 'gender', 'level',
            'target', 'is_coach',
        ]


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email',
            'height', 'weight',
            'first_name', 'last_name', 'date_of_birth',
            'image', 'desc', 'gender', 'level',
            'target', 'is_coach',
        ]
