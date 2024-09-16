from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views.autocomplete_views import CourseAutocompleteView
from .views.views import (
    CategoryApiViewSet,
    CourseApiViewSet,
    DayCreateApiView,
    DayDeleteApiView,
    ModuleCreateApiView,
    ModuleDeleteApiView,
    ModuleUpdateApiView,
)

course_router = DefaultRouter()
course_router.register(r"courses", CourseApiViewSet)

category_router = DefaultRouter()
category_router.register(r"categories", CategoryApiViewSet)

urlpatterns = [
    path("", include(course_router.urls)),
    path("", include(category_router.urls)),
    path("day/create/<int:pk>/", DayCreateApiView.as_view()),
    path("day/delete/<int:pk>/", DayDeleteApiView.as_view()),
    path("module/create/<int:pk>/", ModuleCreateApiView.as_view()),
    path("module/delete/<int:pk>/", ModuleDeleteApiView.as_view()),
    path("module/update/<int:pk>/", ModuleUpdateApiView.as_view()),
    path("autocomplete/courses/", CourseAutocompleteView.as_view()),
]
