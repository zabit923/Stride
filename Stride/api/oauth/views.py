from django.shortcuts import render
from rest_framework.decorators import api_view

from .serializers import GoogleAuth


def google_login(request):
    return render(request, 'oauth/google_login.html')


@api_view(["POST"])
def google_auth(request):
    """ Подтверждение авторизации через Google
    """
    google_data = GoogleAuth(data=request.data)
    if google_data.is_valid():
        token = google.check_google_auth(google_data.data)
        return Response(token)
    else:
        return AuthenticationFailed(code=403, detail='Bad data Google')