from drf_spectacular.utils import OpenApiParameter, extend_schema, extend_schema_view
from rest_framework.generics import ListAPIView

from ..models import Course
from ..serializers import ShortCourseSerializer


@extend_schema_view(
    get=extend_schema(
        parameters=[
            OpenApiParameter(
                name="title",
                type=int,
                location=OpenApiParameter.QUERY,
                description="Название",
            )
        ],
    ),
)
class CourseAutocompleteView(ListAPIView):
    serializer_class = ShortCourseSerializer

    def get_queryset(self):
        queryset = Course.objects.all()
        q = self.request.GET.get("title", "")
        return queryset.filter(title__icontains=q)
