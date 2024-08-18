from rest_framework import serializers
from django.contrib.auth import get_user_model

from .models import Comment, Rating


User = get_user_model()


class AuthorShortSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'first_name', 'last_name', 'image')


class CommentSerializer(serializers.ModelSerializer):
    author = AuthorShortSerializer(read_only=True)
    created_at = serializers.ReadOnlyField()

    class Meta:
        model = Comment
        fields = ['id', 'author', 'course', 'parent', 'text', 'created_at']


class CommentUpdate(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ['id', 'text',]


class RatingSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())

    class Meta:
        model = Rating
        fields = ['id', 'user', 'course', 'rating',]
        read_only_fields = ['id',]
