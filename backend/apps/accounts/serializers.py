from django.contrib.auth import get_user_model
from rest_framework import serializers

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'date_joined']
        read_only_fields = ['id', 'date_joined']


class OTPRequestSerializer(serializers.Serializer):
    mobile_number = serializers.CharField(max_length=20)

    def validate_mobile_number(self, value):
        # Normalize: remove spaces, ensure starts with +
        value = value.strip().replace(' ', '')
        if not value.startswith('+'):
            value = '+88' + value  # Default Bangladesh country code
        return value


class OTPVerifySerializer(serializers.Serializer):
    mobile_number = serializers.CharField(max_length=20)
    code = serializers.CharField(max_length=6, min_length=6)

    def validate_mobile_number(self, value):
        value = value.strip().replace(' ', '')
        if not value.startswith('+'):
            value = '+88' + value
        return value
