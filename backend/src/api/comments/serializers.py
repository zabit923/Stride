from rest_framework import serializers

from .models import Review


class ReviewSerializer(serializers.ModelSerializer):
    author = serializers.ReadOnlyField(source='author.username')
    created_at = serializers.ReadOnlyField()

    class Meta:
        model = Review
        fields = ['id', 'author', 'post', 'parent', 'text', 'created_at']


class ReviewUpdate(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = ['id', 'text',]