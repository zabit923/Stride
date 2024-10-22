from django.contrib.auth import get_user_model
from django.db.models import Avg
from rest_framework import serializers

from ..comments.models import Rating
from .models import Category, Course, Day, Module, MyCourses

User = get_user_model()


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = (
            "id",
            "title",
            "image",
        )


class ModuleSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(required=False)
    data = serializers.FileField(required=False)
    order = serializers.IntegerField(read_only=True)

    class Meta:
        model = Module
        fields = (
            "id",
            "title",
            "image",
            "desc",
            'order',
            "time_to_pass",
            "data",
            "day",
        )

    def create(self, validated_data):
        day = validated_data.get("day")
        count_modules = day.modules.count()
        validated_data['order'] = count_modules + 1

        return super().create(validated_data)

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation.pop("day", None)
        return representation


class ModuleUpdateSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(required=False)
    data = serializers.FileField(required=False)

    class Meta:
        model = Module
        fields = (
            "id",
            "title",
            "image",
            "desc",
            'order',
            "time_to_pass",
            "data",
            "day",
        )

    def shift_module_orders(self, instance, new_order):
        day = instance.day

        if new_order > instance.order:
            modules_to_shift = Module.objects.filter(
                day=day,
                order__gt=instance.order,
                order__lte=new_order
            )
            for module in modules_to_shift:
                module.order -= 1
                module.save()
        elif new_order < instance.order:
            modules_to_shift = Module.objects.filter(
                day=day,
                order__lt=instance.order,
                order__gte=new_order
            )
            for module in modules_to_shift:
                module.order += 1
                module.save()

        instance.order = new_order

    def update(self, instance, validated_data):
        validated_data.pop("day", None)

        new_order = validated_data.get('order')
        if new_order and new_order != instance.order:
            self.shift_module_orders(instance, new_order)

        return super().update(instance, validated_data)

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation.pop("day", None)
        return representation


class DaySerializer(serializers.ModelSerializer):
    modules = ModuleSerializer(many=True, read_only=True)

    class Meta:
        model = Day
        fields = (
            "id",
            "modules",
            "course",
        )

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation.pop("course", None)
        return representation


class AuthorShortSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "first_name", "last_name")


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
            "id",
            "author",
            "title",
            "price",
            "image",
            "desc",
            "category",
            "created_at",
            "count_days",
            "bought",
            "bought_count",
            'is_draft',
            "rating",
            "my_rating",
        )

    def get_count_days(self, obj: Course):
        return obj.days.count()

    def get_bought(self, obj):
        user = self.context["request"].user
        return MyCourses.objects.filter(user=user, course=obj).exists()

    def get_bought_count(self, obj):
        return obj.buyers.count()

    def get_rating(self, obj):
        avg_rating = obj.ratings.aggregate(average=Avg("rating"))["average"]
        if avg_rating is not None:
            return round(avg_rating, 1)
        return None

    def get_my_rating(self, obj):
        user = self.context["request"].user
        try:
            rating = Rating.objects.get(user=user, course=obj)
            return {"id": rating.id, "rating": rating.rating}
        except Rating.DoesNotExist:
            return None


class CourseSerializer(serializers.ModelSerializer):
    author = AuthorShortSerializer(read_only=True)
    days = DaySerializer(read_only=True, many=True)
    bought_count = serializers.SerializerMethodField(read_only=True)
    image = serializers.ImageField(required=False)
    bought = serializers.SerializerMethodField(read_only=True)
    rating = serializers.SerializerMethodField(read_only=True)
    my_rating = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Course
        fields = (
            "id",
            "author",
            "title",
            "price",
            "image",
            "desc",
            "category",
            "created_at",
            "days",
            "bought_count",
            "bought",
            "rating",
            'is_draft',
            "my_rating",
        )

    def get_bought_count(self, obj):
        return obj.buyers.count()

    def get_bought(self, obj):
        user = self.context["request"].user
        return MyCourses.objects.filter(user=user, course=obj).exists()

    def get_rating(self, obj):
        avg_rating = obj.ratings.aggregate(average=Avg("rating"))["average"]
        if avg_rating is not None:
            return round(avg_rating, 1)
        return None

    def get_my_rating(self, obj):
        user = self.context["request"].user
        try:
            rating = Rating.objects.get(user=user, course=obj)
            return {"id": rating.id, "rating": rating.rating}
        except Rating.DoesNotExist:
            return None


class BuyCourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyCourses
        fields = ["course"]

    def create(self, validated_data):
        user = self.context["request"].user
        course = validated_data["course"]
        my_course, created = MyCourses.objects.get_or_create(user=user, course=course)
        return my_course
