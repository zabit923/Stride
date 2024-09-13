from rest_framework.permissions import BasePermission
from django.contrib.auth import get_user_model


User = get_user_model()


class IsCoach(BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.user.is_coach:
            return True


class IsAdminOrSelf(BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.user.is_staff:
            return True
        return obj == request.user


class IsOwnerDay(BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        if obj.course.author == request.user:
            return True
        return False


class IsOwnerModule(BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        if obj.day.course.author == request.user:
            return True
        return False


class IsOwnerCourse(BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        if obj.author == request.user:
            return True
        return False
