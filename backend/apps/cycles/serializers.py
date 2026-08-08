from rest_framework import serializers
from .models import CycleLog, SymptomLog


class SymptomLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = SymptomLog
        fields = ['id', 'date', 'symptom', 'severity', 'notes', 'created_at']
        read_only_fields = ['id', 'created_at']


class CycleLogSerializer(serializers.ModelSerializer):
    symptoms = SymptomLogSerializer(many=True, read_only=True)
    duration = serializers.ReadOnlyField()

    class Meta:
        model = CycleLog
        fields = [
            'id', 'start_date', 'end_date', 'flow_intensity',
            'notes', 'duration', 'symptoms', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class CycleLogCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CycleLog
        fields = ['start_date', 'end_date', 'flow_intensity', 'notes']

    def validate_start_date(self, value):
        from datetime import date
        if value > date.today():
            raise serializers.ValidationError("Start date cannot be in the future.")
        return value
