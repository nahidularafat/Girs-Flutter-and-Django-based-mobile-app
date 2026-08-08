from django.urls import path
from . import views

urlpatterns = [
    path('', views.cycle_list, name='cycle-list'),
    path('<int:pk>/', views.cycle_detail, name='cycle-detail'),
    path('<int:cycle_pk>/symptoms/', views.log_symptom, name='symptom-log'),
    path('predictions/', views.predictions, name='predictions'),
    path('history/', views.cycle_history, name='cycle-history'),
]
