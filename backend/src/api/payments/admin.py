from django.contrib import admin

from .models import Wallet, RequestFunds


@admin.register(Wallet)
class WalletAdmin(admin.ModelAdmin):
    list_display = ('user', 'balance')
    search_fields = ('user__username', 'user__first_name', 'user__last_name')


@admin.register(RequestFunds)
class RequestFundsAdmin(admin.ModelAdmin):
    list_display = ('user', 'amount', 'created_at', 'status')
    search_fields = ('user__username', 'bank_name')
    list_filter = ('created_at', 'status')
    list_editable = ('status',)
    ordering = ('-created_at',)
