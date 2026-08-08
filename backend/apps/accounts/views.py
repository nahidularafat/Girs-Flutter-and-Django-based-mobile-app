import random
import string
from datetime import timedelta

from django.conf import settings
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from .models import OTPCode
from .serializers import UserSerializer, OTPRequestSerializer, OTPVerifySerializer

User = get_user_model()


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


@api_view(['POST'])
@permission_classes([AllowAny])
def request_otp(request):
    """Request an OTP for mobile number verification."""
    serializer = OTPRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    mobile_number = serializer.validated_data['mobile_number']

    # Invalidate old OTPs
    OTPCode.objects.filter(mobile_number=mobile_number, is_used=False).update(is_used=True)

    # Generate 6-digit OTP
    code = '123456' if settings.MOCK_OTP else ''.join(random.choices(string.digits, k=6))
    OTPCode.objects.create(mobile_number=mobile_number, code=code)

    response_data = {
        'message': f'OTP sent to {mobile_number}',
        'expires_in_minutes': settings.OTP_EXPIRY_MINUTES,
    }

    # In dev/mock mode, return OTP in response
    if settings.MOCK_OTP:
        response_data['otp'] = code
        response_data['note'] = 'DEV MODE: OTP included in response. Remove in production.'

    return Response(response_data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def verify_otp(request):
    """Verify OTP and return JWT tokens. Creates user if first login."""
    serializer = OTPVerifySerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    mobile_number = serializer.validated_data['mobile_number']
    code = serializer.validated_data['code']

    expiry_threshold = timezone.now() - timedelta(minutes=settings.OTP_EXPIRY_MINUTES)
    otp = OTPCode.objects.filter(
        mobile_number=mobile_number,
        code=code,
        is_used=False,
        created_at__gte=expiry_threshold,
    ).order_by('-created_at').first()

    if not otp:
        return Response(
            {'error': 'Invalid or expired OTP.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    otp.is_used = True
    otp.save()

    # Get or create user
    user, created = User.objects.get_or_create(username=mobile_number)
    tokens = get_tokens_for_user(user)

    return Response({
        'tokens': tokens,
        'user': UserSerializer(user).data,
        'is_new_user': created,
        'onboarding_required': not hasattr(user, 'profile'),
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def google_login(request):
    """Verify Google ID token and return JWT tokens."""
    token = request.data.get('id_token')
    if not token:
        return Response({'error': 'id_token required'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        from google.oauth2 import id_token as google_id_token
        from google.auth.transport import requests as google_requests
        idinfo = google_id_token.verify_oauth2_token(
            token, google_requests.Request(), settings.GOOGLE_CLIENT_ID if settings.GOOGLE_CLIENT_ID else None
        )
        email = idinfo.get('email', '')
        google_id = idinfo.get('sub', '')
        name = idinfo.get('name', '')

        user, created = User.objects.get_or_create(
            username=f'google_{google_id}',
            defaults={'email': email, 'first_name': name.split()[0] if name else ''}
        )
        tokens = get_tokens_for_user(user)

        return Response({
            'tokens': tokens,
            'user': UserSerializer(user).data,
            'is_new_user': created,
            'onboarding_required': not hasattr(user, 'profile'),
        }, status=status.HTTP_200_OK)

    except ValueError as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
def delete_account(request):
    """Permanently delete user and all associated data."""
    user = request.user
    user.delete()
    return Response({'message': 'Account deleted successfully.'}, status=status.HTTP_204_NO_CONTENT)
