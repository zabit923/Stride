from django.contrib.auth import get_user_model
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response

from .serializers import UserSerializer, UserUpdateSerializer
from .permissions import IsAdminOrSelf, IsOwner


User = get_user_model()


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_permissions(self):
        if self.action == 'destroy':
            self.permission_classes = [IsAdminOrSelf]
        elif self.action == 'update':
            self.permission_classes = [IsOwner]
        elif self.action == 'get_me':
            self.permission_classes = [IsAuthenticated]
        else:
            self.permission_classes = [AllowAny]
        return super().get_permissions()

    def get_serializer_class(self):
        if self.action == 'update':
            self.serializer_class = UserUpdateSerializer
        else:
            self.serializer_class = UserSerializer
        return super().get_serializer_class()

    @action(detail=False, methods=['GET'], url_path='me', pagination_class=None)
    def get_me(self, request):
        user = request.user
        serialized_data = UserSerializer(user).data
        return Response(serialized_data)
