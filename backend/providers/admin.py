from django.contrib import admin
from .models import Provider


@admin.register(Provider)
class ProviderAdmin(admin.ModelAdmin):
	list_display = (
		'name',
		'email',
		'phone',
		'skills',
		'verification_status',
	)
	search_fields = ('name', 'email', 'phone')