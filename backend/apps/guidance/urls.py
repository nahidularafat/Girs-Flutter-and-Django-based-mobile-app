from django.urls import path
from . import views

urlpatterns = [
    path('today/', views.today_guidance, name='guidance-today'),
]
