from rest_framework.exceptions import AuthenticationFailed
from django.conf import settings
from google.oauth2 import id_token
from google.auth.transport import requests

from users.models import User
from .. import serializers
from .base_auth import create_token


def check_google_auth(google_user: serializers.GoogleAuthSerializer) -> dict:
    try:
        id_token.verify_oauth2_token(
            google_user['token'], requests.Request(), settings.GOOGLE_CLIENT_ID
        )
    except ValueError:
        raise AuthenticationFailed(code=403, detail='Bad token Google')

    user, _ = User.objects.get_or_create(email=google_user['email'], username=google_user['username'])
    return create_token(user)
