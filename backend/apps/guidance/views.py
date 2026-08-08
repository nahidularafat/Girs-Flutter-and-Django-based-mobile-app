from rest_framework.decorators import api_view
from rest_framework.response import Response

from apps.cycles.models import CycleLog, SymptomLog
from apps.cycles.prediction import calculate_predictions
from .gemini_client import get_personalized_tip
from datetime import date


@api_view(['GET'])
def today_guidance(request):
    """Returns personalized daily guidance based on current cycle phase and logged symptoms."""
    # Get predictions to determine current phase
    cycles = list(CycleLog.objects.filter(user=request.user).order_by('-start_date')[:7])

    try:
        profile = request.user.profile
        default_cycle_length = profile.avg_cycle_length
        default_period_duration = profile.avg_period_duration
    except Exception:
        default_cycle_length = 28
        default_period_duration = 5

    prediction = calculate_predictions(cycles, default_cycle_length, default_period_duration)
    phase = prediction.get('current_phase', 'follicular')

    # Get today's logged symptoms
    today = date.today()
    today_symptoms = []
    if cycles:
        current_cycle = cycles[0]
        today_symptoms = list(
            SymptomLog.objects.filter(cycle=current_cycle, date=today)
            .values_list('symptom', flat=True)
        )

    lang = request.query_params.get('lang', 'en')
    tip = get_personalized_tip(phase=phase, symptoms=today_symptoms, lang=lang)

    return Response({
        'phase': phase,
        'cycle_day': prediction.get('current_cycle_day', 1),
        'logged_symptoms': today_symptoms,
        'guidance': tip,
        'disclaimer': 'This is general wellness guidance, not medical advice. For persistent or severe symptoms, please consult a doctor.',
    })
