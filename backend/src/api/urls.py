from django.urls import path, include


urlpatterns = [
    path('oauth/', include('api.oauth.urls')),
    path('users/', include('api.users.urls')),
    path('', include('api.courses.urls')),
    # path('comments/', include('api.comments.urls')),
]
