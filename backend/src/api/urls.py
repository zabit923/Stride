from django.urls import include, path

urlpatterns = [
    path("oauth/", include("api.oauth.urls")),
    path("users/", include("api.users.urls")),
    path('payments/', include('api.payments.urls')),
    path("", include("api.courses.urls")),
    path("", include("api.comments.urls")),
]
