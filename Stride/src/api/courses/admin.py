from django.contrib import admin

from .models import (
    Category,
    Course,
    Day
)


admin.site.register(Category)
admin.site.register(Course)
admin.site.register(Day)
