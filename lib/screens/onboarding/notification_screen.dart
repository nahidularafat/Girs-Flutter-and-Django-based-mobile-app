import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/primary_button.dart';


class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});
  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    final data = ref.read(onboardingDataProvider);

    // Ensure required fields have defaults
    final profileData = {
      'mobile_number': data['mobile_number'] ?? '',
      'age': data['age'] ?? 25,
      'marital_status': data['marital_status'] ?? 'undisclosed',
      'avg_cycle_length': data['avg_cycle_length'] ?? 28,
      'avg_period_duration': data['avg_period_duration'] ?? 5,
      'notifications_enabled': _notificationsEnabled,
      if (data['latitude'] != null) 'latitude': data['latitude'],
      if (data['longitude'] != null) 'longitude': data['longitude'],
      if (data['location_name'] != null) 'location_name': data['location_name'],
    };

    // Try to save profile (non-blocking — navigate regardless)
    try {
      await ref.read(profileProvider.notifier).saveProfile(profileData);
    } catch (_) {}

    // Log first period cycle
    final lastPeriodDate = data['last_period_date'];
    if (lastPeriodDate != null) {
      try {
        await ApiService().logCycle({
          'start_date': lastPeriodDate,
          'notes': 'First logged period (onboarding)',
        });
      } catch (_) {}
    }

    // Always navigate to home
    if (mounted) {
      ref.invalidate(predictionProvider);
      ref.invalidate(guidanceProvider);
      ref.invalidate(cyclesProvider);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text('STEP 6 OF 6', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 40),
              const Text('🔔', textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                AppStrings.notificationsTitle,
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.notificationsSubtitle,
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('📱', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.enableNotifications, style: AppTextStyles.subtitle1),
                          Text('Period & ovulation reminders', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: "All done! Let's go 🌸",
                onPressed: _isLoading ? null : _finish,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              Text(
                'You can change notification settings anytime in your profile.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
