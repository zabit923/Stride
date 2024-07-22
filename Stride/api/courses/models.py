from django.db import models
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _


User = get_user_model()


class Course(models.Model):
    name = models.CharField(_('Название'), max_length=50)
    author = models.ForeignKey(
        User,
        verbose_name=_('Автор'),
        related_name='courses',
        on_delete=models.SET_NULL,
        null=True
    )
    price = models.IntegerField(_('Цена'))
    desc = models.TextField(_('Описание'), max_length=500)

