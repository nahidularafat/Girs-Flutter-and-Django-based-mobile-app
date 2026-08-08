from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, OTPCode

admin.site.register(User, UserAdmin)

@admin.register(OTPCode)
class OTPCodeAdmin(admin.ModelAdmin):
    list_display = ('mobile_number', 'code', 'is_used', 'created_at')
    search_fields = ('mobile_number',)
    list_filter = ('is_used', 'created_at')
