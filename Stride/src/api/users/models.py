from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import gettext_lazy as _
from phonenumber_field.modelfields import PhoneNumberField


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

    username = models.CharField(
        _("username"),
        max_length=150,
        unique=True,
        blank=True,
        null=True
    )
    first_name = models.CharField(_('first_name'), max_length=150)
    last_name = models.CharField(_('last_name'), max_length=150)
    phone_number = PhoneNumberField(
        _("phone number"),
        region="RU",
        null=True,
        help_text="+7 (123) 123-45-67",
    )
    email = models.EmailField(_('email'), unique=True)
    desc = models.TextField(
        _('description'),
        max_length=300,
        blank=True, null=True
    )
    image = models.ImageField(
        _('avatar'),
        upload_to='avatars/',
        default='images/pngegg.png',
        null=True, blank=True
    )

    height = models.IntegerField(_('height in centimeters'), null=True, blank=True)
    weight = models.IntegerField(_('weight in kilograms'), null=True, blank=True)
    date_of_birth = models.DateField(_('date of Birth'), null=True, blank=True)

    gender = models.CharField(
        _('gender'),
        max_length=1,
        choices=GenderChoises.choices,
        null=True,
        blank=True
    )
    level = models.CharField(
        _('level'),
        max_length=3,
        choices=LevelChoises.choices,
        null=True, blank=True
    )
    target = models.CharField(
        _('target'),
        max_length=2,
        choices=TargetChoises.choices,
        null=True, blank=True
    )

    is_coach = models.BooleanField(_('is_coach'), default=False)

    def __str__(self):
        return f'{self.username} | {self.weight} кг | {self.height} см | {self.gender}, {self.target}, {self.level}'

    class Meta:
        verbose_name = 'Пользователь'
        verbose_name_plural = 'Пользователи'
