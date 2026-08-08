from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import UserProfile
from .serializers import UserProfileSerializer


@api_view(['GET', 'PUT', 'PATCH'])
def profile_detail(request):
    """Get or update the authenticated user's profile."""
    try:
        profile = request.user.profile
    except UserProfile.DoesNotExist:
        if request.method == 'GET':
            return Response(
                {'detail': 'Profile not created yet. Complete onboarding.'},
                status=status.HTTP_404_NOT_FOUND
            )
        profile = None

    if request.method == 'GET':
        serializer = UserProfileSerializer(profile)
        return Response(serializer.data)

    if request.method in ['PUT', 'PATCH']:
        partial = request.method == 'PATCH'
        if profile:
            serializer = UserProfileSerializer(profile, data=request.data, partial=partial)
        else:
            serializer = UserProfileSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
