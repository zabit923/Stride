# Generated by Django 5.0.6 on 2024-07-05 17:39

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0003_alter_user_date_of_birth_alter_user_gender_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='gender',
            field=models.CharField(blank=True, choices=[('M', 'Муж.'), ('F', 'Жен.')], max_length=1, null=True, verbose_name='Пол'),
        ),
        migrations.AlterField(
            model_name='user',
            name='image',
            field=models.ImageField(blank=True, default='/static/images/pngegg.png', null=True, upload_to='avatars/', verbose_name='Аватар'),
        ),
        migrations.AlterField(
            model_name='user',
            name='level',
            field=models.CharField(blank=True, choices=[('BEG', 'Beginner'), ('MID', 'Midlle'), ('ADV', 'Advanced'), ('PRO', 'Professional')], max_length=3, null=True, verbose_name='Уровень подготовки'),
        ),
        migrations.AlterField(
            model_name='user',
            name='target',
            field=models.CharField(blank=True, choices=[('LW', 'Lose_weight'), ('GW', 'Gain_weight'), ('HL', 'Health'), ('OT', 'Other')], max_length=2, null=True, verbose_name='Цель'),
        ),
    ]