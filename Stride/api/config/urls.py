from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from drf_spectacular.views import SpectacularSwaggerView, SpectacularAPIView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView


urlpatterns = [
    path('admin/', admin.site.urls),
    path('_schema/', SpectacularAPIView.as_view(), name="schema"),
    path('api/swagger/', SpectacularSwaggerView.as_view(url_name="schema"), name='swagger'),

    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # path('oauth/authorize/', oauth2_views.AuthorizedTokenDeleteView.as_view(), name='authorize'),
    # path('oauth/token/', oauth2_views.TokenView.as_view(), name='token'),
    # path('oauth/revoke-token/', oauth2_views.RevokeTokenView.as_view(), name='revoke-token'),

    path('api/v1/users/', include('users.urls')),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
