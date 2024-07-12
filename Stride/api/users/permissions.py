from rest_framework import permissions


class IsAdminOrSelf(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.user.is_staff:
            return True
        return obj == request.user


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj == request.user
