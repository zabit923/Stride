from drf_spectacular.utils import (
    OpenApiResponse,
    extend_schema,
    extend_schema_view,
    inline_serializer,
)
from rest_framework import serializers
from rest_framework.decorators import api_view
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.response import Response

from .serializers import GoogleAuthSerializer
from .services import google


@extend_schema_view(
    post=extend_schema(
        request=GoogleAuthSerializer,
        responses={
            200: OpenApiResponse(
                response=inline_serializer(
                    name="Response",
                    fields={
                        "refresh_token": serializers.CharField(),
                        "access_token": serializers.CharField(),
                    },
                )
            )
        },
    )
)
@api_view(["POST"])
def google_auth(request):
    google_data = GoogleAuthSerializer(data=request.data)
    if google_data.is_valid():
        token = google.check_google_auth(google_data.data)
        return Response(token)
    else:
        raise AuthenticationFailed(code=403, detail="Bad data Google")
