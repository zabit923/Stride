# Generated by Django 5.0.6 on 2024-07-11 15:17

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ("users", "0007_alter_user_number"),
    ]

    operations = [
        migrations.RenameField(
            model_name="user",
            old_name="number",
            new_name="phone",
        ),
    ]
