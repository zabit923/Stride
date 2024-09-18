from django.urls import path
from .views import RequestFundsView

urlpatterns = [
    path('request-funds', RequestFundsView.as_view(), name='request-funds'),
]
