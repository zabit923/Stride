from rest_framework import serializers

from .models import (
    Course,
    Day,
    Module,
)


class ModuleSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(required=False)

    class Meta:
        model = Module
        fields = (
            'id',
            'title',
            'image',
            'desc',
            'time_to_pass',
            'data',
        )


class DaySerializer(serializers.ModelSerializer):
    modules = ModuleSerializer(many=True)

    class Meta:
        model = Day
        fields = (
            'id',
            'modules',
        )


class CourseSerializer(serializers.ModelSerializer):
    author = serializers.HiddenField(default=serializers.CurrentUserDefault())
    days = DaySerializer(many=True, required=False)
    image = serializers.ImageField(required=False)

    class Meta:
        model = Course
        fields = (
            'id',
            'author',
            'title',
            'price',
            'image',
            'desc',
            'category',
            'created_at',
            'days'
        )

    def create(self, validated_data):
        days_data = validated_data.pop('days', [])
        course = Course.objects.create(**validated_data)

        for day_data in days_data:
            modules_data = day_data.pop('modules', [])
            day = Day.objects.create(course=course, **day_data)
            for module_data in modules_data:
                Module.objects.create(day=day, **module_data)
        return course

    def update(self, instance, validated_data):
        days_data = validated_data.pop('days', [])

        for day_data in days_data:
            modules_data = day_data.pop('modules', [])
            day = Day.objects.create(course=instance, **day_data)
            for module_data in modules_data:
                Module.objects.create(day=day, **module_data)
        return instance
