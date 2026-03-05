from django.contrib import admin
from .models import Member


@admin.register(Member)
class MemberAdmin(admin.ModelAdmin):
    list_display = ['__str__', 'membership', 'status', 'goal', 'member_since', 'expiry_date']
    list_filter = ['status', 'membership', 'goal']
    search_fields = ['user__first_name', 'user__last_name', 'user__email']