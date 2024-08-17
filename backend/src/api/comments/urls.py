from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    CommentViewSet,
    RatingViewSet
)


comment_router = DefaultRouter()
comment = comment_router.register(r'comments', CommentViewSet)

rating_router = DefaultRouter()
rating = rating_router.register(r'rating', RatingViewSet)


urlpatterns = [
    path('', include(comment_router.urls)),
    path('', include(rating_router.urls)),
]
