# Generated by Django 5.0.6 on 2024-09-29 08:25

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('courses', '0011_alter_category_image_alter_course_image_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='course',
            name='is_draft',
            field=models.BooleanField(default=False, verbose_name='Черновик'),
        ),
    ]
