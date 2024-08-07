from rest_framework import serializers

from .models import (
    Course,
    Day,
    Module,
    MyCourses,
    Category
)


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = (
            'title',
            'image',
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


class ShortCourseSerializer(serializers.ModelSerializer):
    author = serializers.HiddenField(default=serializers.CurrentUserDefault())
    count_days = serializers.SerializerMethodField()
    image = serializers.ImageField(required=False)
    bought = serializers.SerializerMethodField()

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
            'count_days',
            'bought',
        )

    def get_count_days(self, obj: Course):
        return obj.days.count()

    def get_bought(self, obj):
        user = self.context["request"].user
        return MyCourses.objects.filter(user=user, course=obj).exists()


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


class BuyCourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyCourses
        fields = ['course']

    def create(self, validated_data):
        user = self.context['request'].user
        course = validated_data['course']
        my_course, created = MyCourses.objects.get_or_create(user=user, course=course)
        return my_course
