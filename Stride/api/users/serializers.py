from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password


User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """
    Сериализатор пользователя.
    """
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_again = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email',
            'first_name', 'last_name', 'about_me',
            'link', 'tg_link', 'linkedin_link',
            'image', 'password', 'password_again'
        ]

    def validate(self, attrs):
        if attrs['password'] != attrs['password_again']:
            raise serializers.ValidationError({'password': 'Пароли не совпадают'})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_again')
        image = validated_data.pop('image', None)
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            about_me=validated_data['about_me'],
            link=validated_data['link'],
            tg_link=validated_data['tg_link'],
            linkedin_link=validated_data['linkedin_link'],
        )
        if image:
            user.image = image
        user.set_password(validated_data['password'])
        user.save()
        return user