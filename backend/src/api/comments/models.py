from django.db import models
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _

from api.courses.models import Course


User = get_user_model()


class Comment(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='review_author')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='review')
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, verbose_name='parent', blank=True, null=True)

    text = models.TextField('Текст', max_length=500)
    created_at = models.DateTimeField(_('Дата написания'), auto_now_add=True)

    def __str__(self):
        return f'{self.author} | {self.course}'

    class Meta:
        verbose_name = 'Комментарий'
        verbose_name_plural = 'Комментарии'
