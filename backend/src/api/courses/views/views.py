from decimal import Decimal

from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import status
from rest_framework.decorators import action, api_view
from rest_framework.exceptions import NotFound
from rest_framework.generics import CreateAPIView, DestroyAPIView, UpdateAPIView
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet

from common.utils import CustomHttpResponseRedirect
from ..filters import CategoryFilter
from ..models import Category, Course, Day, Module
from ..permissions import (
    IsCoach,
    IsOwnerCourse,
    IsOwnerDay,
    IsOwnerModule,
    IsNotOwnerCourse
)
from ..serializers import (
    BuyCourseSerializer,
    CategorySerializer,
    CourseSerializer,
    DaySerializer,
    ModuleSerializer,
    MyCourses,
    ShortCourseSerializer,
)

User = get_user_model()


class CourseApiViewSet(ModelViewSet):
    queryset = Course.objects.all()
    filter_backends = [
        DjangoFilterBackend,
    ]
    filterset_class = CategoryFilter

    def get_serializer_class(self):
        if self.action in [
            "list",
            "my_courses",
            "my_bought_courses",
            "courses_by_id",
            "celebrities_courses",
            "recommended_courses",
        ]:
            return ShortCourseSerializer
        elif self.action == "retrieve":
            user = self.request.user
            course = self.get_object()
            if (
                MyCourses.objects.filter(user=user, course=course).exists()
                or course.author == user
            ):
                return CourseSerializer
            else:
                return ShortCourseSerializer
        elif self.action == "buy_course":
            return BuyCourseSerializer
        return CourseSerializer

    def get_permissions(self):
        if self.action in [
            "list",
            "retrieve",
            "my_courses",
            "courses_by_id",
            "my_bought_courses",
            "celebrities_courses",
            "recommended_courses",
        ]:
            self.permission_classes = [IsAuthenticated]
        elif self.action == 'buy_course':
            self.permission_classes = [IsNotOwnerCourse]
        elif self.action in ["update", "destroy"]:
            self.permission_classes = [IsOwnerCourse]
        else:
            self.permission_classes = [IsCoach]
        return super().get_permissions()

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated])
    def buy_course(self, request, pk=None):
        course = self.get_object()
        user = request.user

        if MyCourses.objects.filter(user=user, course=course).exists():
            return Response(
                {"detail": "Вы уже купили этот курс."},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer = self.get_serializer(data={"course": course.id})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        author_wallet = getattr(course.author, 'wallet', None)
        author_wallet.balance += Decimal(course.price)
        author_wallet.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def list(self, request, *args, **kwargs):
        courses = Course.objects.filter(is_draft=False)
        page = self.paginate_queryset(courses)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

    @action(detail=False, methods=["get"], permission_classes=[IsAuthenticated])
    def my_courses(self, request):
        user = request.user
        courses = Course.objects.filter(author=user)
        serializer = self.get_serializer(courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=True, methods=["get"], permission_classes=[IsAuthenticated])
    def courses_by_id(self, request, pk=None):
        author = get_object_or_404(User, pk=pk)
        courses = Course.objects.filter(author=author, is_draft=False)
        serializer = self.get_serializer(courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=["get"], permission_classes=[IsAuthenticated])
    def my_bought_courses(self, request):
        user = request.user
        bought_courses = Course.objects.filter(buyers__user=user)
        serializer = self.get_serializer(bought_courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=["get"], permission_classes=[IsAuthenticated])
    def celebrities_courses(self, request):
        celebrity_users = User.objects.filter(is_celebrity=True)
        courses = Course.objects.filter(author__in=celebrity_users, is_draft=False)
        serializer = self.get_serializer(courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=["get"], permission_classes=[IsAuthenticated])
    def recommended_courses(self, request):
        user = request.user
        user_target = user.target
        if user_target == "LW":
            category = Category.objects.get(title="Сброс веса")
            courses = Course.objects.filter(category=category, is_draft=False)
            if len(courses) == 0:
                courses = Course.objects.all()
        elif user_target == "GW":
            category = Category.objects.get(title="Набор веса")
            courses = Course.objects.filter(category=category, is_draft=False)
            if len(courses) == 0:
                courses = Course.objects.all()
        elif user_target == "HL":
            category = Category.objects.get(title="Здоровье")
            courses = Course.objects.filter(category=category, is_draft=False)
            if len(courses) == 0:
                courses = Course.objects.filter(is_draft=False)
        else:
            courses = Course.objects.filter(is_draft=False)
        serializer = self.get_serializer(courses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


@api_view(['GET'])
def deep_link_course(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    app_deep_link = f"stridecourses://courses/{course_id}"
    print(app_deep_link)
    return CustomHttpResponseRedirect(app_deep_link)


class CategoryApiViewSet(ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [IsAuthenticated, IsAdminUser]

    def get_permissions(self):
        if self.action == "list":
            self.permission_classes = [IsAuthenticated]
        return super().get_permissions()


class DayCreateApiView(CreateAPIView):
    queryset = Day.objects.all()
    serializer_class = DaySerializer
    permission_classes = [
        IsOwnerDay,
    ]

    def create(self, request, *args, **kwargs):
        course_id = self.kwargs.get("pk")
        if not Course.objects.filter(id=course_id).exists():
            raise NotFound(detail="Course with this ID does not exist.")
        data = request.data.copy()
        data["course"] = course_id

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class DayDeleteApiView(DestroyAPIView):
    queryset = Day.objects.all()
    serializer_class = DaySerializer
    permission_classes = [
        IsOwnerDay,
    ]


class ModuleCreateApiView(CreateAPIView):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer
    permission_classes = [
        IsOwnerModule,
    ]

    def create(self, request, *args, **kwargs):
        day_id = self.kwargs.get("pk")
        if not Day.objects.filter(id=day_id).exists():
            raise NotFound(detail="Day with this ID does not exist.")
        data = request.data.copy()
        data["day"] = day_id

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class ModuleDeleteApiView(DestroyAPIView):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer
    permission_classes = [
        IsOwnerModule,
    ]


class ModuleUpdateApiView(UpdateAPIView):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer
    permission_classes = [
        IsOwnerModule,
    ]
