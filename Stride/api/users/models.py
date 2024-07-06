from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    class GenderChoises(models.TextChoices):
        MALE = 'M', 'Муж.'
        FEMALE = 'F', 'Жен.'

    class LevelChoises(models.TextChoices):
        BEGINNER = 'BEG', 'Beginner'
        MIDLLE = 'MID', 'Midlle'
        ADVANCED = 'ADV', 'Advanced'
        PROFESSIONAL = 'PRO', 'Professional'

    class TargetChoises(models.TextChoices):
        LOSE_WEIGHT = 'LW', 'Lose_weight'
        GAIN_WEIGHT = 'GW', 'Gain_weight'
        HEALTH = 'HL', 'Health'
        OTHER = 'OT', 'Other'

    first_name = models.CharField(verbose_name='Имя', max_length=150)
    last_name = models.CharField(verbose_name='Фамилия', max_length=150)
    number = models.IntegerField(verbose_name='Номер телефона', blank=True, null=True)
    email = models.EmailField(verbose_name='email', blank=True, null=True)
    desc = models.TextField(verbose_name='Описание', max_length=300, blank=True, null=True)
    image = models.ImageField(verbose_name='Аватар', upload_to='avatars/', default='images/pngegg.png', null=True, blank=True)

    height = models.IntegerField(verbose_name='Рост в см.', null=True, blank=True)
    weight = models.IntegerField(verbose_name='Вес в кг.', null=True, blank=True)
    date_of_birth = models.DateField(verbose_name='Дата рождения', null=True, blank=True)

    gender = models.CharField(
        verbose_name='Пол', max_length=1,
        choices=GenderChoises.choices, null=True, blank=True
    )
    level = models.CharField(
        verbose_name='Уровень подготовки',
        max_length=3, choices=LevelChoises.choices, null=True, blank=True
    )
    target = models.CharField(
        verbose_name='Цель', max_length=2,
        choices=TargetChoises.choices, null=True, blank=True
    )

    is_coach = models.BooleanField(verbose_name='Тренер', default=False)

    def __str__(self):
        return f'{self.username} | {self.weight} кг | {self.height} см | {self.gender}, {self.target}, {self.level}'

    class Meta:
        verbose_name = 'Пользователь'
        verbose_name_plural = 'Пользователи'
