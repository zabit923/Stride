from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import CourseApiViewSet


router = DefaultRouter()
router.register(r'', CourseApiViewSet)


urlpatterns = [
    path('', include(router.urls)),
]
