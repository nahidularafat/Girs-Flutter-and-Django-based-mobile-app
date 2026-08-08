import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import 'onboarding_scaffold.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepText: 'STEP 1 OF 6',
      title: AppStrings.locationPermission,
      nextRoute: '/onboarding/age',
      content: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: AppColors.ovulationGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text('📍', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 20),
                Text(
                  AppStrings.locationReason,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1.copyWith(color: Colors.white, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _InfoRow(icon: '🌍', text: 'Regional wellness tips tailored to your area'),
          const SizedBox(height: 12),
          _InfoRow(icon: '⏰', text: 'Reminders adjusted to your timezone'),
          const SizedBox(height: 12),
          _InfoRow(icon: '🔒', text: 'Location is never shared with third parties'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTextStyles.body2)),
      ],
    );
  }
}
