from rest_framework_simplejwt.tokens import AccessToken, RefreshToken


def create_token(user) -> dict:
    refresh = RefreshToken.for_user(user)
    access = AccessToken.for_user(user)
    return {
        "refresh": str(refresh),
        "access": str(access),
    }
