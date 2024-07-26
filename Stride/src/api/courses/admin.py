from django.contrib import admin
from .models import Category, Course, Day, Module


class DayInline(admin.TabularInline):
    model = Day
    extra = 1
    fields = ['title']


class ModuleInline(admin.TabularInline):
    model = Module
    extra = 1
    fields = ['title', 'image', 'desc', 'time_to_pass']


@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    inlines = [DayInline]


@admin.register(Day)
class DayAdmin(admin.ModelAdmin):
    inlines = [ModuleInline]


admin.site.register(Category)
admin.site.register(Module)
