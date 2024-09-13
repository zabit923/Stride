from django_filters import rest_framework as filters

from .models import Course


class CategoryFilter(filters.FilterSet):
    category = filters.BaseInFilter(field_name="category__id")

    class Meta:
        model = Course
        fields = [
            "category",
        ]
