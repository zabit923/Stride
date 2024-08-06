from rest_framework.permissions import BasePermission


class IsCommentOwnerOrAdmin(BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.user and request.user.is_staff:
            return True
        if obj.author == request.user:
            return True
        return False
