from django.db import models
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _


User = get_user_model()


class Category(models.Model):
    title = models.CharField('Категория', max_length=128)
    image = models.ImageField('Изображение', upload_to='category_images')

    class Meta:
        verbose_name = 'Категория'
        verbose_name_plural = 'Категории'

    def __str__(self):
        return f'{self.title}'


class Module(models.Model):
    title = models.CharField(_('Название'), max_length=128)
    image = models.ImageField(
        _('Изображение'),
        upload_to='course_images',
        blank=True, null=True
    )
    desc = models.TextField(
        _('Описание'),
        max_length=100,
        blank=True, null=True
    )
    time_to_pass = models.IntegerField(
        _('Время на прохождение'),
        blank=True, null=True
    )
    data = models.BinaryField(
        _('Данные'),
    )
    day = models.ForeignKey(
        'Day',
        verbose_name=_('День'),
        on_delete=models.CASCADE,
        related_name='modules'
    )

    def __str__(self):
        return f'{self.title} - {self.day.id} - {self.day.course.title}'

    class Meta:
        verbose_name = 'Модуль'
        verbose_name_plural = 'Модули'


class Day(models.Model):
    course = models.ForeignKey(
        'Course',
        verbose_name=_('Курс'),
        related_name='days',
        on_delete=models.CASCADE,
        null=True
    )

    def __str__(self):
        return f'id: {self.id} |{self.course.title}'

    class Meta:
        verbose_name = 'День'
        verbose_name_plural = 'Дни'


class Course(models.Model):
    title = models.CharField(_('Название'), max_length=50)
    author = models.ForeignKey(
        User,
        verbose_name=_('Автор'),
        related_name='courses',
        on_delete=models.SET_NULL,
        null=True
    )
    price = models.IntegerField(_('Цена'))
    desc = models.TextField(_('Описание'), max_length=2000)
    image = models.ImageField(
        _('Изображение'),
        upload_to='course_images',
        blank=True, null=True
    )
    category = models.ForeignKey(
        Category,
        verbose_name=_('Категория'),
        related_name='courses',
        on_delete=models.SET_NULL,
        null=True
    )
    created_at = models.DateField(_('Дата создания'), auto_now_add=True)

    def __str__(self):
        return f'{self.title} | автор: {self.author.username} | {self.price} руб.'

    class Meta:
        verbose_name = 'Курс'
        verbose_name_plural = 'Курсы'


class MyCourses(models.Model):
    user = models.ForeignKey(User, verbose_name='Пользователь', related_name='my_courses', on_delete=models.CASCADE)
    course = models.ForeignKey(Course, verbose_name='Курс', related_name='buyers', on_delete=models.CASCADE)

    def __str__(self):
        return f'{self.user.username} - {self.course.title}'

    class Meta:
        verbose_name = 'Мои курсы'
        verbose_name_plural = 'Мои курсы'
