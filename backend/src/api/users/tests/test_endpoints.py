from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from rest_framework import status
from parameterized import parameterized

from common.factories.users_factories import UserFactory


User = get_user_model()


class UserViewSetTest(APITestCase):
    @classmethod
    def setUpTestData(cls):
        cls.admin_user = UserFactory.create(is_staff=True)
        cls.normal_user = UserFactory.create()
        cls.celebrity_user = UserFactory.create(is_celebrity=True)

    def setUp(self):
        self.url = '/api/v1/users/'
        self.client.force_authenticate(user=self.normal_user)

    @parameterized.expand([
        ('normal_user', status.HTTP_200_OK),
        ('admin_user', status.HTTP_200_OK)
    ])
    def test_list_users(self, user_role, expected_status):
        user = self.admin_user if user_role == 'admin_user' else self.normal_user
        self.client.force_authenticate(user=user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, expected_status)

    def test_get_me(self):
        response = self.client.get(f'{self.url}me/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], self.normal_user.id)

    def test_get_all_celebrity(self):
        response = self.client.get(f'{self.url}get_all_celebrity/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn(self.celebrity_user.id, [user['id'] for user in response.data])

    def test_update_user(self):
        data = {'first_name': 'Updated Name'}
        response = self.client.patch(f'{self.url}{self.normal_user.id}/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.normal_user.refresh_from_db()
        self.assertEqual(self.normal_user.first_name, 'Updated Name')

    @parameterized.expand([
        ('admin_user', status.HTTP_204_NO_CONTENT),
        ('normal_user', status.HTTP_403_FORBIDDEN)
    ])
    def test_delete_user(self, user_role, expected_status):
        user_to_delete = UserFactory.create()
        self.client.force_authenticate(user=self.admin_user if user_role == 'admin_user' else self.normal_user)
        response = self.client.delete(f'{self.url}{user_to_delete.id}/')
        self.assertEqual(response.status_code, expected_status)
        if expected_status == status.HTTP_204_NO_CONTENT:
            self.assertFalse(User.objects.filter(id=user_to_delete.id).exists())
        else:
            self.assertTrue(User.objects.filter(id=user_to_delete.id).exists())
