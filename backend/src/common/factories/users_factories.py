import factory
from factory import LazyFunction
from factory.django import DjangoModelFactory
from django.contrib.auth import get_user_model

from ..testing import generate_phone_number


User = get_user_model()


class UserFactory(DjangoModelFactory):
    class Meta:
        model = User
        django_get_or_create = ['email']

    first_name = factory.Faker('first_name')
    last_name = factory.Faker('last_name')
    email = factory.Faker('email')
    phone_number = LazyFunction(generate_phone_number)
    username = factory.Sequence(lambda n: f'user_{n}')
    is_staff = False
    is_celebrity = False
