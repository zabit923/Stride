from rest_framework.permissions import IsAuthenticated
from rest_framework.viewsets import ModelViewSet
from django.contrib.auth import get_user_model

from .permissions import IsCoach, IsAdminOrSelf
from .models import (
    Course,
)
from .serializers import CourseSerializer


User = get_user_model()


class CourseApiViewSet(ModelViewSet):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    permission_classes = [IsAuthenticated, IsCoach, IsAdminOrSelf]
