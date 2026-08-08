import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import 'onboarding_scaffold.dart';

class MaritalStatusScreen extends ConsumerStatefulWidget {
  const MaritalStatusScreen({super.key});
  @override
  ConsumerState<MaritalStatusScreen> createState() => _MaritalStatusScreenState();
}

class _MaritalStatusScreenState extends ConsumerState<MaritalStatusScreen> {
  String? _selected;

  final List<_Option> _options = [
    _Option(value: 'single', label: AppStrings.maritalSingle, emoji: '🌸'),
    _Option(value: 'married', label: AppStrings.maritalMarried, emoji: '💍'),
    _Option(value: 'undisclosed', label: AppStrings.maritalUndisclosed, emoji: '🤍'),
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepText: 'STEP 3 OF 6',
      title: AppStrings.maritalStatus,
      nextEnabled: _selected != null,
      onNext: () {
        ref.read(onboardingDataProvider.notifier).update((s) => {...s, 'marital_status': _selected});
        context.go('/onboarding/last-period');
      },
      content: Column(
        children: _options.map((opt) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => setState(() => _selected = opt.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: _selected == opt.value ? AppColors.primaryLight : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selected == opt.value ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(opt.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Text(opt.label, style: AppTextStyles.subtitle1),
                  const Spacer(),
                  if (_selected == opt.value)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _Option {
  final String value, label, emoji;
  _Option({required this.value, required this.label, required this.emoji});
}
