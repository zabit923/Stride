from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework import status, viewsets
from rest_framework.decorators import action, api_view
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .permissions import IsAdminOrSelf, IsOwner
from .serializers import (
    CustomTokenObtainPairSerializer,
    UserCreateSerializer,
    UserGetSerializer,
    UserUpdateSerializer,
)
from common.utils import CustomHttpResponseRedirect

User = get_user_model()


class CustomTokenObtainPairView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = CustomTokenObtainPairSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        tokens = serializer.get_tokens_for_user(user)
        return Response(tokens, status=status.HTTP_200_OK)


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserCreateSerializer

    def get_permissions(self):
        if self.action == "destroy":
            self.permission_classes = [IsAdminOrSelf]
        elif self.action in ("update", "partial_update"):
            self.permission_classes = [IsOwner]
        elif self.action == "get_me":
            self.permission_classes = [IsAuthenticated]
        else:
            self.permission_classes = [AllowAny]
        return super().get_permissions()

    def get_serializer_class(self):
        if self.request.method in {"PATCH", "PUT"}:
            self.serializer_class = UserUpdateSerializer
        elif self.action in ["list", "retrieve"]:
            self.serializer_class = UserGetSerializer
        else:
            self.serializer_class = UserCreateSerializer
        return super().get_serializer_class()

    @action(detail=False, methods=["GET"], url_path="me", pagination_class=None)
    def get_me(self, request):
        user = request.user
        serialized_data = UserGetSerializer(user).data
        return Response(serialized_data)

    @action(detail=False, methods=["GET"], pagination_class=None)
    def get_all_celebrity(self, request):
        celebrities = User.objects.filter(is_celebrity=True)
        serialized_data = UserGetSerializer(celebrities, many=True).data
        return Response(serialized_data)


@api_view(['GET'])
def deep_link_user_profile(request, user_id):
    user = get_object_or_404(User, id=user_id)
    app_deep_link = f"stridecourses://users/{user_id}"
    print(app_deep_link)
    return CustomHttpResponseRedirect(app_deep_link)
