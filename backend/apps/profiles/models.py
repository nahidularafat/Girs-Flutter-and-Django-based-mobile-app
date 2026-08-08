from django.conf import settings
from django.db import models


class UserProfile(models.Model):
    """Stores all onboarding & health preference data for a user."""

    MARITAL_STATUS_CHOICES = [
        ('single', 'Single'),
        ('married', 'Married'),
        ('undisclosed', 'Prefer not to say'),
    ]

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='profile'
    )
    mobile_number = models.CharField(max_length=20, unique=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    location_name = models.CharField(max_length=255, blank=True)

    age = models.PositiveIntegerField()
    date_of_birth = models.DateField(null=True, blank=True)

    marital_status = models.CharField(
        max_length=20,
        choices=MARITAL_STATUS_CHOICES,
        default='undisclosed'
    )

    avg_cycle_length = models.PositiveIntegerField(default=28)
    avg_period_duration = models.PositiveIntegerField(default=5)

    notifications_enabled = models.BooleanField(default=True)
    fcm_token = models.TextField(blank=True)

    consent_given_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-consent_given_at']

    def __str__(self):
        return f"Profile of {self.user.username}"
