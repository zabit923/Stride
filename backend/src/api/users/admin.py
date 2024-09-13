from django.contrib import admin
from .models import User
from dal import autocomplete
from django import forms


class UserForm(forms.ModelForm):
    class Meta:
        model = User
        fields = '__all__'
        widgets = {
            'username': autocomplete.ModelSelect2(url='user-autocomplete'),
            'phone_number': autocomplete.ModelSelect2(url='user-autocomplete'),
            'email': autocomplete.ModelSelect2(url='user-autocomplete'),
        }


class UserAdmin(admin.ModelAdmin):
    list_display = (
        'username',
        'email',
        'phone_number',
        'first_name',
        'last_name',
        'is_coach',
        'is_celebrity'
    )
    exclude = ('user_permissions', 'groups', 'date_joined', 'last_login')
    list_filter = ('gender', 'level', 'target', 'is_coach', 'is_celebrity')
    search_fields = ('username', 'email', 'phone_number')
    autocomplete_fields = []


admin.site.register(User, UserAdmin)
