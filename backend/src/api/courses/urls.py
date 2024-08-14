from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    CourseApiViewSet,
    CategoryApiViewSet,
    DayApiViewSet,
    ModuleApiViewSet,
)


course_router = DefaultRouter()
course_router.register(r'courses', CourseApiViewSet)

category_router = DefaultRouter()
category_router.register(r'categories', CategoryApiViewSet)

day_router = DefaultRouter()
day_router.register(r'days', DayApiViewSet, basename='day')

module_router = DefaultRouter()
module_router.register(r'modules', ModuleApiViewSet, basename='module')

urlpatterns = [
    path('', include(course_router.urls)),
    path('', include(category_router.urls)),
    path('', include(day_router.urls)),
    path('', include(module_router.urls)),
]
