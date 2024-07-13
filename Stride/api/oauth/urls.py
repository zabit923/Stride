from django.urls import path, include

from .views import google_login


urlpatterns = [
    path('google_login/', google_login),
]
