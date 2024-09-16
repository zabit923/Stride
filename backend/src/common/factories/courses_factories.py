import factory
from factory.django import DjangoModelFactory

from api.courses.models import Category, Course, Day, Module, MyCourses
from .users_factories import UserFactory


class CategoryFactory(DjangoModelFactory):
    class Meta:
        model = Category

    title = factory.Faker("word")
    image = factory.django.ImageField()


class CourseFactory(DjangoModelFactory):
    class Meta:
        model = Course

    title = factory.Faker("sentence", nb_words=4)
    author = factory.SubFactory(UserFactory)
    price = factory.Faker("random_number", digits=4)
    desc = factory.Faker("paragraph")
    image = factory.django.ImageField()
    category = factory.SubFactory(CategoryFactory)


class DayFactory(DjangoModelFactory):
    class Meta:
        model = Day

    course = factory.SubFactory(CourseFactory)


class ModuleFactory(DjangoModelFactory):
    class Meta:
        model = Module

    title = factory.Faker("sentence", nb_words=3)
    desc = factory.Faker("paragraph")
    day = factory.SubFactory(DayFactory)
    image = factory.django.ImageField()
    data = factory.django.FileField()


class MyCoursesFactory(DjangoModelFactory):
    class Meta:
        model = MyCourses

    user = factory.SubFactory(UserFactory)
    course = factory.SubFactory(CourseFactory)
