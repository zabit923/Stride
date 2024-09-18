from django.core.exceptions import ValidationError
from django.core.validators import RegexValidator
from django.db import models
from django.contrib.auth import get_user_model
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils.translation import gettext_lazy as _
from decimal import Decimal
from phonenumber_field.modelfields import PhoneNumberField


User = get_user_model()


class Wallet(models.Model):
    user = models.OneToOneField(
        User,
        verbose_name=_('Кошелек'),
        on_delete=models.CASCADE,
        related_name='wallet'
    )
    balance = models.DecimalField(
        verbose_name=_('Сумма'),
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00')
    )

    def __str__(self):
        return f'{self.user.username}: {self.balance}'

    class Meta:
        verbose_name = 'Кошелек'
        verbose_name_plural = 'Кошельки'


class RequestFunds(models.Model):
    class StatusChoises(models.TextChoices):
        IN_PROCESS = "In process", "В процессе"
        COMPLETED = "Completed", "Завершено"

    user = models.ForeignKey(
        User,
        verbose_name=_('Запрос на получение'),
        on_delete=models.SET_NULL,
        null=True,
        related_name='fund_request'
    )
    card_number = models.CharField(
        verbose_name=_('Номер карты'),
        max_length=20,
        validators=[
            RegexValidator(
                regex=r'^\d{4}(?:\s\d{4}){2,4}$',
                message="Введите номер карты в формате: 'XXXX XXXX XXXX XXXX' или 'XXXX XXXX XXXX XXXX XXX'"
            )
        ],
        blank=True,
        null=True,
        help_text="Введите номер карты"
    )
    phone_number = PhoneNumberField(
        _("phone number"),
        region="RU",
        null=True,
        blank=True,
        help_text="+7 (123) 123-45-67",
        unique=True,
    )
    amount = models.DecimalField(
        verbose_name=_('Сумма'),
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00')
    )
    created_at = models.DateField(_("Дата создания"), auto_now_add=True)
    status = models.CharField(
        _("status"), max_length=10, choices=StatusChoises.choices
    )

    def clean(self):
        super().clean()
        if not (self.card_number or self.phone_number):
            raise ValidationError(_('Введите либо номер карты, либо номер телефона.'))

    def __str__(self):
        return f'{self.user.username}: {self.amount} | {self.created_at}'

    class Meta:
        verbose_name = 'Запрос'
        verbose_name_plural = 'Запросы'


@receiver(post_save, sender=User)
def create_wallet_for_coach(sender, instance, created, **kwargs):
    if instance.is_coach and not hasattr(instance, 'wallet'):
        Wallet.objects.get_or_create(user=instance)
