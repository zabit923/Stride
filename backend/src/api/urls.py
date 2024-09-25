from django.urls import include, path

from .users.views import deep_link_user_profile
from .courses.views.views import deep_link_course

urlpatterns = [
    path("oauth/", include("api.oauth.urls")),
    path("users/", include("api.users.urls")),
    path('payments/', include('api.payments.urls')),
    path('deeplink/users/<int:user_id>', deep_link_user_profile, name='deep_link_user_profile'),
    path('deeplink/courses/<int:course_id>', deep_link_course, name='deep_link_course'),
    path("", include("api.courses.urls")),
    path("", include("api.comments.urls")),
]
