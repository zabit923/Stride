from django.contrib.auth import get_user_model
from rest_framework import mixins, status, viewsets
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from .models import Comment, Rating
from .permissions import IsCommentOwnerOrAdmin
from .serializers import CommentSerializer, CommentUpdate, RatingSerializer

User = get_user_model()


class CommentViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.DestroyModelMixin,
    mixins.UpdateModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Comment.objects.all()
    permission_classes = [IsAuthenticated, IsCommentOwnerOrAdmin]
    pagination_class = None

    def get_permissions(self):
        if self.action == "retrieve":
            self.permission_classes = [AllowAny]
        elif self.action == "create":
            self.permission_classes = [IsAuthenticated]
        elif self.action in ["update", "destroy"]:
            self.permission_classes = [IsCommentOwnerOrAdmin]
        return super().get_permissions()

    def get_serializer_class(self):
        if self.request.method in ["PUT", "PATCH"]:
            self.serializer_class = CommentUpdate
        else:
            self.serializer_class = CommentSerializer
        return super().get_serializer_class()

    def retrieve(self, request, *args, **kwargs):
        course_id = kwargs.get("pk")
        reviews = Comment.objects.filter(course_id=course_id)
        serializer = self.get_serializer(reviews, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


class RatingViewSet(
    mixins.CreateModelMixin,
    mixins.UpdateModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Rating.objects.all()
    serializer_class = RatingSerializer
    permission_classes = [IsAuthenticated]

    def get_permissions(self):
        if self.action == "retrieve":
            self.permission_classes = [AllowAny]
        elif self.action == "create":
            self.permission_classes = [IsAuthenticated]
        elif self.action in ["update", "destroy"]:
            self.permission_classes = [IsCommentOwnerOrAdmin]
        return super().get_permissions()
