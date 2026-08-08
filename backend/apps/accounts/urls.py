from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path('otp/request/', views.request_otp, name='otp-request'),
    path('otp/verify/', views.verify_otp, name='otp-verify'),
    path('google/', views.google_login, name='google-login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('account/delete/', views.delete_account, name='account-delete'),
]
