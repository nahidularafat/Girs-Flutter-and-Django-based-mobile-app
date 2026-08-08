from django.db import models


class TipCache(models.Model):
    """Caches AI-generated or pre-written tips per phase/symptom combo."""

    PHASE_CHOICES = [
        ('menstrual', 'Menstrual'),
        ('follicular', 'Follicular'),
        ('ovulation', 'Ovulation'),
        ('luteal', 'Luteal'),
    ]

    phase = models.CharField(max_length=20, choices=PHASE_CHOICES)
    symptom_tags = models.CharField(max_length=255, blank=True)  # comma-separated
    title = models.CharField(max_length=255)
    content = models.TextField()
    is_ai_generated = models.BooleanField(default=False)
    generated_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-generated_at']

    def __str__(self):
        return f"{self.phase} tip: {self.title[:50]}"
