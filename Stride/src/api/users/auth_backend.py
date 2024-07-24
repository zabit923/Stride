from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model


User = get_user_model()


class CustomAuthBackend(ModelBackend):
    def authenticate(self, request, phone_number=None, password=None, **kwargs):
        users = User.objects.filter(phone_number=phone_number)

        for user in users:
            if user.check_password(password) and self.user_can_authenticate(user):
                return user
        return None
