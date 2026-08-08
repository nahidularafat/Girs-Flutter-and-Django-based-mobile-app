from rest_framework import serializers
from .models import UserProfile


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'id', 'mobile_number', 'latitude', 'longitude', 'location_name',
            'age', 'date_of_birth', 'marital_status',
            'avg_cycle_length', 'avg_period_duration',
            'notifications_enabled', 'fcm_token', 'consent_given_at', 'updated_at',
        ]
        read_only_fields = ['id', 'consent_given_at', 'updated_at']

    def validate_age(self, value):
        if value < 13:
            raise serializers.ValidationError(
                "Must be at least 13 years old to use this app."
            )
        if value > 60:
            raise serializers.ValidationError("Please enter a valid age.")
        return value

    def validate_avg_cycle_length(self, value):
        if not (21 <= value <= 35):
            raise serializers.ValidationError("Cycle length must be between 21 and 35 days.")
        return value

    def validate_avg_period_duration(self, value):
        if not (2 <= value <= 8):
            raise serializers.ValidationError("Period duration must be between 2 and 8 days.")
        return value
