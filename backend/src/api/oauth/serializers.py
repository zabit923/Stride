from rest_framework import serializers


class GoogleAuthSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    token = serializers.CharField()
