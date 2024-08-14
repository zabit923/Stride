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
