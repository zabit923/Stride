from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase, APIClient

from common.factories.courses_factories import (
    UserFactory,
    CategoryFactory,
    CourseFactory,
    DayFactory,
    ModuleFactory
)
from api.courses.models import Course, MyCourses


class CourseApiTests(APITestCase):
    @classmethod
    def setUpTestData(cls):
        cls.user = UserFactory()
        cls.coach = UserFactory(is_coach=True)
        cls.category = CategoryFactory()
        cls.course = CourseFactory(author=cls.coach, category=cls.category)
        cls.day = DayFactory(course=cls.course)
        cls.module = ModuleFactory(day=cls.day)

    def setUp(self):
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

    def test_list_courses(self):
        """Проверка списка курсов"""
        url = reverse("course-list")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data), 1)

    def test_retrieve_course(self):
        """Проверка получения курса по ID"""
        url = reverse("course-detail", kwargs={"pk": self.course.id})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["id"], self.course.id)

    def test_buy_course(self):
        """Проверка покупки курса"""
        url = reverse("course-buy-course", kwargs={"pk": self.course.id})
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(MyCourses.objects.filter(user=self.user, course=self.course).exists())

    def test_create_course_forbidden(self):
        """Проверка, что не-коуч не может создать курс"""
        data = {
            "title": "Новый курс",
            "price": 1000,
            "desc": "Описание курса",
            "category": self.category.id
        }
        url = reverse("course-list")
        response = self.client.post(url, data=data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_delete_course(self):
        """Проверка удаления курса владельцем"""
        self.client.force_authenticate(user=self.coach)
        url = reverse("course-detail", kwargs={"pk": self.course.id})
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Course.objects.filter(id=self.course.id).exists())
