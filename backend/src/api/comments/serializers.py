from rest_framework import serializers

from .models import Comment, Rating


class CommentSerializer(serializers.ModelSerializer):
    author = serializers.HiddenField(default=serializers.CurrentUserDefault())
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
