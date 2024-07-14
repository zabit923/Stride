from rest_framework.decorators import api_view
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.response import Response
from .serializers import GoogleAuth
from .services import google


@api_view(["POST"])
def google_auth(request):
    google_data = GoogleAuth(data=request.data)
    if google_data.is_valid():
        token = google.check_google_auth(google_data.data)
        return Response(token)
    else:
        raise AuthenticationFailed(code=403, detail='Bad data Google')
