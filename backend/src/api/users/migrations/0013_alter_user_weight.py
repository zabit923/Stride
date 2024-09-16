# Generated by Django 5.0.6 on 2024-07-15 00:16

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("users", "0012_alter_user_date_of_birth_alter_user_desc_and_more"),
    ]

    operations = [
        migrations.AlterField(
            model_name="user",
            name="weight",
            field=models.IntegerField(
                blank=True, null=True, verbose_name="weight in kilograms"
            ),
        ),
    ]
