from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import CycleLog, SymptomLog
from .serializers import CycleLogSerializer, CycleLogCreateSerializer, SymptomLogSerializer
from .prediction import calculate_predictions


@api_view(['GET', 'POST'])
def cycle_list(request):
    if request.method == 'GET':
        cycles = CycleLog.objects.filter(user=request.user)
        serializer = CycleLogSerializer(cycles, many=True)
        return Response(serializer.data)

    if request.method == 'POST':
        serializer = CycleLogCreateSerializer(data=request.data)
        if serializer.is_valid():
            cycle = serializer.save(user=request.user)
            return Response(
                CycleLogSerializer(cycle).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def cycle_detail(request, pk):
    try:
        cycle = CycleLog.objects.get(pk=pk, user=request.user)
    except CycleLog.DoesNotExist:
        return Response({'error': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        return Response(CycleLogSerializer(cycle).data)

    if request.method in ['PUT', 'PATCH']:
        serializer = CycleLogCreateSerializer(
            cycle, data=request.data, partial=request.method == 'PATCH'
        )
        if serializer.is_valid():
            serializer.save()
            return Response(CycleLogSerializer(cycle).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    if request.method == 'DELETE':
        cycle.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(['POST'])
def log_symptom(request, cycle_pk):
    try:
        cycle = CycleLog.objects.get(pk=cycle_pk, user=request.user)
    except CycleLog.DoesNotExist:
        return Response({'error': 'Cycle not found.'}, status=status.HTTP_404_NOT_FOUND)

    serializer = SymptomLogSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(cycle=cycle)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def predictions(request):
    """Calculate and return next period predictions."""
    cycles = list(CycleLog.objects.filter(user=request.user).order_by('-start_date')[:7])

    try:
        profile = request.user.profile
        default_cycle_length = profile.avg_cycle_length
        default_period_duration = profile.avg_period_duration
    except Exception:
        default_cycle_length = 28
        default_period_duration = 5

    result = calculate_predictions(cycles, default_cycle_length, default_period_duration)
    return Response(result)


@api_view(['GET'])
def cycle_history(request):
    """Returns cycle history with trend statistics."""
    cycles = CycleLog.objects.filter(user=request.user).order_by('-start_date')

    lengths = []
    for i in range(len(cycles) - 1):
        length = (cycles[i].start_date - cycles[i + 1].start_date).days
        if 15 <= length <= 45:
            lengths.append(length)

    stats = {}
    if lengths:
        stats = {
            'average_cycle_length': round(sum(lengths) / len(lengths), 1),
            'shortest_cycle': min(lengths),
            'longest_cycle': max(lengths),
            'total_cycles_logged': len(cycles),
            'cycle_lengths_trend': list(reversed(lengths)),
        }

    return Response({
        'cycles': CycleLogSerializer(cycles, many=True).data,
        'statistics': stats,
    })
