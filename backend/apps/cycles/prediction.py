"""
Prediction Engine for Girls App.

Calculates:
- Next period start date
- Ovulation date
- Fertile window (start & end)
- Confidence range (±days)

Based on rolling average of the last 3-6 logged cycles.
"""

from datetime import date, timedelta
from typing import Optional


def calculate_predictions(
    cycles: list,
    default_cycle_length: int = 28,
    default_period_duration: int = 5,
) -> dict:
    """
    Args:
        cycles: list of CycleLog objects ordered by start_date desc
        default_cycle_length: user's profile default
        default_period_duration: user's profile default

    Returns:
        dict with prediction data
    """
    if not cycles:
        return _build_prediction(
            last_period_date=date.today(),
            avg_cycle_length=default_cycle_length,
            avg_period_duration=default_period_duration,
            num_cycles_used=0,
        )

    # Use the most recent cycle as reference
    last_cycle = cycles[0]
    last_period_date = last_cycle.start_date

    # Calculate cycle lengths from consecutive cycles
    cycle_lengths = []
    for i in range(len(cycles) - 1):
        length = (cycles[i].start_date - cycles[i + 1].start_date).days
        if 15 <= length <= 45:  # Sanity check
            cycle_lengths.append(length)

    # Use only the last 6 cycle lengths
    cycle_lengths = cycle_lengths[:6]

    if cycle_lengths:
        avg_cycle_length = round(sum(cycle_lengths) / len(cycle_lengths))
    else:
        avg_cycle_length = default_cycle_length

    return _build_prediction(
        last_period_date=last_period_date,
        avg_cycle_length=avg_cycle_length,
        avg_period_duration=default_period_duration,
        num_cycles_used=len(cycle_lengths),
    )


def _build_prediction(
    last_period_date: date,
    avg_cycle_length: int,
    avg_period_duration: int,
    num_cycles_used: int,
) -> dict:
    next_period_date = last_period_date + timedelta(days=avg_cycle_length)
    ovulation_date = next_period_date - timedelta(days=14)
    fertile_window_start = ovulation_date - timedelta(days=5)
    fertile_window_end = ovulation_date + timedelta(days=1)

    # Confidence range: ±3 days with ≥3 cycles, else ±5 days
    if num_cycles_used >= 3:
        confidence_days = 3
    elif num_cycles_used >= 1:
        confidence_days = 5
    else:
        confidence_days = 7  # No data at all

    # Current phase calculation
    today = date.today()
    days_since_last_period = (today - last_period_date).days
    current_cycle_day = max(1, (days_since_last_period % avg_cycle_length) + 1)
    phase = _get_phase(current_cycle_day, avg_cycle_length, avg_period_duration)

    return {
        'last_period_date': last_period_date.isoformat(),
        'next_period_date': next_period_date.isoformat(),
        'next_period_date_early': (next_period_date - timedelta(days=confidence_days)).isoformat(),
        'next_period_date_late': (next_period_date + timedelta(days=confidence_days)).isoformat(),
        'ovulation_date': ovulation_date.isoformat(),
        'fertile_window_start': fertile_window_start.isoformat(),
        'fertile_window_end': fertile_window_end.isoformat(),
        'avg_cycle_length': avg_cycle_length,
        'avg_period_duration': avg_period_duration,
        'confidence_days': confidence_days,
        'num_cycles_used': num_cycles_used,
        'current_cycle_day': current_cycle_day,
        'current_phase': phase,
        'days_until_next_period': max(0, (next_period_date - today).days),
    }


def _get_phase(cycle_day: int, cycle_length: int, period_duration: int) -> str:
    """Returns the current menstrual phase."""
    if cycle_day <= period_duration:
        return 'menstrual'
    elif cycle_day <= cycle_length // 2 - 2:
        return 'follicular'
    elif cycle_day <= cycle_length // 2 + 2:
        return 'ovulation'
    else:
        return 'luteal'
