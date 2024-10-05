from django.contrib.auth import get_user_model
from django.db import models
from django.utils.translation import gettext_lazy as _

from config.yandex_s3_storage import ClientDocsStorage


User = get_user_model()


class Category(models.Model):
    title = models.CharField("Категория", max_length=128)
    image = models.ImageField(
        "Изображение",
        storage=ClientDocsStorage(),
        upload_to="category_images"
    )

    def save(self, *args, **kwargs):
        try:
            old_instance = Category.objects.get(pk=self.pk)
            if old_instance.image and old_instance.image != self.image:
                old_instance.image.delete(save=False)
        except Category.DoesNotExist:
            pass
        super(Category, self).save(*args, **kwargs)

    class Meta:
        verbose_name = "Категория"
        verbose_name_plural = "Категории"

    def __str__(self):
        return f"{self.title}"


class Module(models.Model):
    title = models.CharField(_("Название"), max_length=128, null=True, blank=True)
    image = models.ImageField(
        _("Изображение"),
        storage=ClientDocsStorage(),
        upload_to="course_images",
        blank=True,
        null=True
    )
    desc = models.TextField(_("Описание"), max_length=100, blank=True, null=True)
    time_to_pass = models.IntegerField(_("Время на прохождение"), blank=True, null=True)
    index = models.IntegerField(_('Индекс'))
    data = models.FileField(
        _("Данные"),
        storage=ClientDocsStorage(),
        upload_to="module_data",
        null=True,
        blank=True
    )
    day = models.ForeignKey(
        "Day", verbose_name=_("День"), on_delete=models.CASCADE, related_name="modules"
    )

    def save(self, *args, **kwargs):
        try:
            old_instance = Module.objects.get(pk=self.pk)

            if old_instance.image and old_instance.image != self.image:
                old_instance.image.delete(save=False)

            if old_instance.data and old_instance.data != self.data:
                old_instance.data.delete(save=False)
        except Module.DoesNotExist:
            pass
        super(Module, self).save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        modules_to_shift = Module.objects.filter(day=self.day, index__gt=self.index)
        for module in modules_to_shift:
            module.index -= 1
            module.save()
        if self.data:
            self.data.delete(save=False)
        if self.image:
            self.image.delete(save=False)
        super().delete(*args, **kwargs)

    def __str__(self):
        return f"{self.title} - {self.day.id} - {self.day.course.title}"

    class Meta:
        verbose_name = "Модуль"
        verbose_name_plural = "Модули"
        ordering = ['index']


class Day(models.Model):
    course = models.ForeignKey(
        "Course",
        verbose_name=_("Курс"),
        related_name="days",
        on_delete=models.CASCADE,
        null=True,
    )

    def __str__(self):
        return f"id: {self.id} |{self.course.title}"

    class Meta:
        verbose_name = "День"
        verbose_name_plural = "Дни"


class Course(models.Model):
    title = models.CharField(_("Название"), max_length=50)
    author = models.ForeignKey(
        User,
        verbose_name=_("Автор"),
        related_name="courses",
        on_delete=models.SET_NULL,
        null=True,
    )
    price = models.IntegerField(_("Цена"))
    desc = models.TextField(_("Описание"), max_length=2000)
    image = models.ImageField(
        _("Изображение"),
        storage=ClientDocsStorage(),
        upload_to="course_images",
        blank=True,
        null=True
    )
    category = models.ForeignKey(
        Category,
        verbose_name=_("Категория"),
        related_name="courses",
        on_delete=models.SET_NULL,
        null=True,
    )
    is_draft = models.BooleanField(_('Черновик'), default=False)
    created_at = models.DateField(_("Дата создания"), auto_now_add=True)

    def save(self, *args, **kwargs):
        try:
            old_instance = Course.objects.get(pk=self.pk)
            if old_instance.image and old_instance.image != self.image:
                old_instance.image.delete(save=False)
        except Course.DoesNotExist:
            pass
        super(Course, self).save(*args, **kwargs)

    def __str__(self):
        return f"{self.title} | автор: {self.author.username} | {self.price} руб."

    class Meta:
        verbose_name = "Курс"
        verbose_name_plural = "Курсы"


class MyCourses(models.Model):
    user = models.ForeignKey(
        User,
        verbose_name="Пользователь",
        related_name="my_courses",
        on_delete=models.CASCADE,
    )
    course = models.ForeignKey(
        Course, verbose_name="Курс", related_name="buyers", on_delete=models.CASCADE
    )

    def __str__(self):
        return f"{self.user.username} - {self.course.title}"

    class Meta:
        verbose_name = "Мои курсы"
        verbose_name_plural = "Мои курсы"
