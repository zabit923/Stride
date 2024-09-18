from rest_framework import serializers

from .models import RequestFunds, Wallet


class RequestFundsSerializer(serializers.ModelSerializer):
    class Meta:
        model = RequestFunds
        fields = ['user', 'card_number', 'phone_number', 'amount', 'bank_name']

    def validate(self, data):
        user = self.context['request'].user
        if not data.get('card_number') and not data.get('phone_number'):
            raise serializers.ValidationError("Необходимо указать либо номер карты, либо номер телефона.")
        try:
            wallet = Wallet.objects.get(user=user)
        except Wallet.DoesNotExist:
            raise serializers.ValidationError("У пользователя нет кошелька.")

        if data['amount'] > wallet.balance:
            raise serializers.ValidationError("Недостаточно средств на счету для совершения транзакции.")
        return data

    def create(self, validated_data):
        user = validated_data['user']
        wallet = Wallet.objects.get(user=user)
        wallet.balance -= validated_data['amount']
        wallet.save()
        return RequestFunds.objects.create(**validated_data)
