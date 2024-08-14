from django.shortcuts import get_object_or_404
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

    def get_serializer_class(self):
        if self.action in ['list', 'my_courses', 'my_bought_courses', 'courses_by_id']:
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

    def get_permissions(self):
        if self.action in [
            'list',
            'retrieve',
            'buy_course',
            'my_courses',
            'my_bought_courses',
        ]:
            self.permission_classes = [IsAuthenticated]
        elif self.action in ['update', 'delete']:
            self.permission_classes = [IsAdminOrSelf]
        else:
            self.permission_classes = [IsCoach]
        return super().get_permissions()

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

    @action(detail=True, methods=['get'], permission_classes=[IsAuthenticated])
    def courses_by_id(self, request, pk=None):
        author = get_object_or_404(User, pk=pk)
        courses = Course.objects.filter(author=author)
        serializer = self.get_serializer(courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_bought_courses(self, request):
        user = request.user
        bought_courses = Course.objects.filter(buyers__user=user)
        serializer = self.get_serializer(bought_courses, many=True)
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
