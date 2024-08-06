from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import CourseApiViewSet, CategoryApiViewSet


course_router = DefaultRouter()
course_router.register(r'courses', CourseApiViewSet)

category_router = DefaultRouter()
category_router.register(r'categories', CategoryApiViewSet)

urlpatterns = [
    path('', include(course_router.urls)),
    path('', include(category_router.urls)),
]
