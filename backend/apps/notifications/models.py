from django.conf import settings
from django.db import models


class FCMToken(models.Model):
    """Stores Firebase Cloud Messaging tokens for push notifications."""
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='fcm_token_obj'
    )
    token = models.TextField()
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"FCM token for {self.user.username}"
