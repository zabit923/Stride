from django.contrib import admin
import nested_admin
from .models import Category, Module, Day, Course, MyCourses


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('title',)
    search_fields = ('title',)


class ModuleInline(nested_admin.NestedStackedInline):
    model = Module
    extra = 1
    readonly_fields = ('day',)


class DayInline(nested_admin.NestedStackedInline):
    model = Day
    inlines = [ModuleInline]
    extra = 1
    readonly_fields = ('course',)


@admin.register(Course)
class CourseAdmin(nested_admin.NestedModelAdmin):
    list_display = ('title', 'author', 'price', 'created_at', 'category')
    list_filter = ('author', 'category')
    search_fields = ('title', 'author__username')
    inlines = [DayInline]


@admin.register(MyCourses)
class MyCoursesAdmin(admin.ModelAdmin):
    list_display = ('user', 'course')
    search_fields = ('user__username', 'course__title')
    list_filter = ('user', 'course')
