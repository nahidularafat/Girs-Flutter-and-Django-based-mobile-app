import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import 'onboarding_scaffold.dart';

class CycleLengthScreen extends ConsumerStatefulWidget {
  const CycleLengthScreen({super.key});
  @override
  ConsumerState<CycleLengthScreen> createState() => _CycleLengthScreenState();
}

class _CycleLengthScreenState extends ConsumerState<CycleLengthScreen> {
  double _cycleLength = 28;
  double _periodDuration = 5;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepText: 'STEP 5 OF 6',
      title: 'Cycle Preferences',
      subtitle: 'These are just starting points — we\'ll learn your pattern over time.',
      onNext: () {
        ref.read(onboardingDataProvider.notifier).update((s) => {
          ...s,
          'avg_cycle_length': _cycleLength.round(),
          'avg_period_duration': _periodDuration.round(),
        });
        context.go('/onboarding/notifications');
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderSection(
            title: AppStrings.cycleLength,
            subtitle: AppStrings.cycleLengthSubtitle,
            value: _cycleLength,
            min: 21,
            max: 35,
            unit: 'days',
            onChanged: (v) => setState(() => _cycleLength = v),
          ),
          const SizedBox(height: 40),
          _SliderSection(
            title: AppStrings.periodDuration,
            subtitle: AppStrings.periodDurationSubtitle,
            value: _periodDuration,
            min: 2,
            max: 8,
            unit: 'days',
            onChanged: (v) => setState(() => _periodDuration = v),
          ),
        ],
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  final String title, subtitle, unit;
  final double value, min, max;
  final Function(double) onChanged;
  const _SliderSection({
    required this.title, required this.subtitle, required this.unit,
    required this.value, required this.min, required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.subtitle1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value.round()} $unit',
                style: AppTextStyles.subtitle1.copyWith(color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.caption),
        const SizedBox(height: 16),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.round()} days', style: AppTextStyles.caption),
            Text('${max.round()} days', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}
