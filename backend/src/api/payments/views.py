from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import RequestFunds
from .serializers import RequestFundsSerializer
from .permissions import IsCoach


class RequestFundsView(APIView):
    queryset = RequestFunds.objects.all()
    serializer_class = RequestFundsSerializer
    permission_classes = [IsCoach]

    def post(self, request):
        serializer = RequestFundsSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response({"message": "Запрос на вывод средств успешно отправлен."}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
