from django.test import TestCase
from unittest.mock import patch
from rest_framework.test import APIClient
from rest_framework import status
from django.urls import reverse
from api.users.models import User


class GoogleAuthTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.url = reverse("google_auth")

    @patch("api.oauth.services.google.id_token.verify_oauth2_token")
    @patch("api.oauth.services.google.User.objects.get_or_create")
    def test_google_auth_success(self, mock_get_or_create, mock_verify_oauth2_token):
        mock_verify_oauth2_token.return_value = {"sub": "valid-google-id"}
        mock_get_or_create.return_value = (User(username="testuser", email="test@example.com"), True)
        data = {
            "username": "testuser",
            "email": "test@example.com",
            "token": "valid-google-token"
        }
        response = self.client.post(self.url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("refresh", response.data)
        self.assertIn("access", response.data)

    @patch("api.oauth.services.google.id_token.verify_oauth2_token")
    def test_google_auth_invalid_token(self, mock_verify_oauth2_token):
        mock_verify_oauth2_token.side_effect = ValueError("Invalid token")
        data = {
            "username": "testuser",
            "email": "test@example.com",
            "token": "invalid-google-token"
        }
        response = self.client.post(self.url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data["detail"], "Bad token Google")

    def test_google_auth_invalid_data(self):
        data = {
            "username": "",
            "email": "invalid-email",
            "token": ""
        }
        response = self.client.post(self.url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data["detail"], "Bad data Google")
