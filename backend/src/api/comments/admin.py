from django.contrib import admin

from .models import Comment, Rating

admin.site.register(Comment)
admin.site.register(Rating)
