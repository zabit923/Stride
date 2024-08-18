from django.contrib import admin
from .models import (
    Category,
    Course,
    Day,
    Module,
    MyCourses
)


admin.site.register(Category)
admin.site.register(Day)
admin.site.register(Module)
admin.site.register(Course)
admin.site.register(MyCourses)
