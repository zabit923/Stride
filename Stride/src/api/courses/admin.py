from django.contrib import admin
from .models import Category, Course, Day, Module


class DayInline(admin.TabularInline):
    model = Day
    extra = 1


class ModuleInline(admin.TabularInline):
    model = Module
    extra = 1
    fields = ['title', 'image', 'desc', 'time_to_pass']


@admin.register(Day)
class DayAdmin(admin.ModelAdmin):
    inlines = [ModuleInline]


admin.site.register(Category)
admin.site.register(Module)
admin.site.register(Course)
