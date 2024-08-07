from rest_framework import status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet, GenericViewSet
from rest_framework.mixins import UpdateModelMixin, DestroyModelMixin
from django.contrib.auth import get_user_model

from .permissions import IsCoach, IsAdminOrSelf
from .models import (
    Course,
    Category,
    Day,
    Module,
)
from .serializers import (
    CourseSerializer,
    ShortCourseSerializer,
    BuyCourseSerializer,
    MyCourses,
    CategorySerializer,
    DaySerializer,
    ModuleSerializer,
)


User = get_user_model()


class CourseApiViewSet(ModelViewSet):
    queryset = Course.objects.all()
    permission_classes = [IsAuthenticated, IsCoach, IsAdminOrSelf]

    def get_serializer_class(self):
        if self.action in ['list', 'my_course']:
            return ShortCourseSerializer
        elif self.action == 'retrieve':
            user = self.request.user
            course = self.get_object()
            if MyCourses.objects.filter(user=user, course=course).exists() or course.author == user:
                return CourseSerializer
            else:
                return ShortCourseSerializer
        elif self.action == 'buy_course':
            return BuyCourseSerializer
        return CourseSerializer

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def buy_course(self, request, pk=None):
        course = self.get_object()
        serializer = self.get_serializer(data={'course': course.id})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_courses(self, request):
        user = request.user
        courses = Course.objects.filter(author=user)
        serializer = self.get_serializer(courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_bought_courses(self, request):
        user = request.user
        bought_courses = Course.objects.filter(buyers__user=user)
        serializer = CourseSerializer(bought_courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class CategoryApiViewSet(ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


class DayApiViewSet(
    UpdateModelMixin,
    DestroyModelMixin,
    GenericViewSet
):
    queryset = Day.objects.all()
    serializer_class = DaySerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


class ModuleApiViewSet(
    UpdateModelMixin,
    DestroyModelMixin,
    GenericViewSet
):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]
