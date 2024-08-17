from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.db.models import Avg

from .models import (
    Course,
    Day,
    Module,
    MyCourses,
    Category
)
from ..comments.models import Rating

User = get_user_model()


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


class AuthorShortSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'first_name', 'last_name')


class ShortCourseSerializer(serializers.ModelSerializer):
    author = AuthorShortSerializer(read_only=True)
    count_days = serializers.SerializerMethodField()
    image = serializers.ImageField(required=False)
    bought = serializers.SerializerMethodField(read_only=True)
    bought_count = serializers.SerializerMethodField(read_only=True)
    rating = serializers.SerializerMethodField(read_only=True)
    my_rating = serializers.SerializerMethodField(read_only=True)

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
            'bought_count',
            'rating',
            'my_rating',
        )

    def get_count_days(self, obj: Course):
        return obj.days.count()

    def get_bought(self, obj):
        user = self.context["request"].user
        return MyCourses.objects.filter(user=user, course=obj).exists()

    def get_bought_count(self, obj):
        return obj.buyers.count()

    def get_rating(self, obj):
        avg_rating = obj.ratings.aggregate(average=Avg('rating'))['average']
        if avg_rating is not None:
            return round(avg_rating, 1)
        return None

    def get_my_rating(self, obj):
        user = self.context['request'].user
        try:
            rating = Rating.objects.get(user=user, course=obj)
            return {
                'id': rating.id,
                'rating': rating.rating
            }
        except Rating.DoesNotExist:
            return None


class CourseSerializer(serializers.ModelSerializer):
    author = serializers.HiddenField(default=serializers.CurrentUserDefault())
    days = DaySerializer(read_only=True)
    bought_count = serializers.SerializerMethodField(read_only=True)
    image = serializers.ImageField(required=False)
    rating = serializers.SerializerMethodField(read_only=True)
    my_rating = serializers.SerializerMethodField(read_only=True)

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
            'days',
            'bought_count',
            'rating',
            'my_rating',
        )

    def get_bought_count(self, obj):
        return obj.buyers.count()

    def get_rating(self, obj):
        avg_rating = obj.ratings.aggregate(average=Avg('rating'))['average']
        if avg_rating is not None:
            return round(avg_rating, 1)
        return None

    def get_my_rating(self, obj):
        user = self.context['request'].user
        rating = Rating.objects.get(user=user, course=obj)
        return {
            'id': rating.id,
            'rating': rating.rating
        }


class BuyCourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyCourses
        fields = ['course']

    def create(self, validated_data):
        user = self.context['request'].user
        course = validated_data['course']
        my_course, created = MyCourses.objects.get_or_create(user=user, course=course)
        return my_course
