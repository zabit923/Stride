from django.contrib import admin
from .models import User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    exclude = ('user_permissions', 'groups', 'date_joined', 'last_login')
