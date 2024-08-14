from django.urls import path

from .views import google_auth


urlpatterns = [
    path('google/', google_auth),
]
