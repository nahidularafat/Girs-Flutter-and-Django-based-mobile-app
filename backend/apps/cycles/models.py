from django.conf import settings
from django.db import models


class CycleLog(models.Model):
    """Logs a single menstrual cycle for a user."""

    FLOW_CHOICES = [
        ('light', 'Light'),
        ('medium', 'Medium'),
        ('heavy', 'Heavy'),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='cycles'
    )
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    flow_intensity = models.CharField(
        max_length=10, choices=FLOW_CHOICES, null=True, blank=True
    )
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-start_date']
        unique_together = ['user', 'start_date']

    def __str__(self):
        return f"{self.user.username} — cycle starting {self.start_date}"

    @property
    def duration(self):
        if self.end_date:
            return (self.end_date - self.start_date).days + 1
        return None


class SymptomLog(models.Model):
    """Logs daily symptoms linked to a cycle."""

    SYMPTOM_CHOICES = [
        ('cramps', 'Cramps'),
        ('headache', 'Headache'),
        ('bloating', 'Bloating'),
        ('mood_swings', 'Mood Swings'),
        ('fatigue', 'Fatigue'),
        ('breast_tenderness', 'Breast Tenderness'),
        ('nausea', 'Nausea'),
        ('acne', 'Acne'),
        ('back_pain', 'Back Pain'),
        ('insomnia', 'Insomnia'),
        ('cravings', 'Cravings'),
        ('spotting', 'Spotting'),
        ('other', 'Other'),
    ]

    cycle = models.ForeignKey(
        CycleLog,
        on_delete=models.CASCADE,
        related_name='symptoms'
    )
    date = models.DateField()
    symptom = models.CharField(max_length=50, choices=SYMPTOM_CHOICES)
    severity = models.PositiveSmallIntegerField(default=1)  # 1-3: mild, moderate, severe
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return f"{self.symptom} on {self.date}"
