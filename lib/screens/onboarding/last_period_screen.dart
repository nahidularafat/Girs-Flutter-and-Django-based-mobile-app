import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import 'onboarding_scaffold.dart';

class LastPeriodScreen extends ConsumerStatefulWidget {
  const LastPeriodScreen({super.key});
  @override
  ConsumerState<LastPeriodScreen> createState() => _LastPeriodScreenState();
}

class _LastPeriodScreenState extends ConsumerState<LastPeriodScreen> {
  DateTime? _selectedDate;
  final DateFormat _fmt = DateFormat('MMMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepText: 'STEP 4 OF 6',
      title: AppStrings.lastPeriodDate,
      subtitle: AppStrings.lastPeriodSubtitle,
      nextEnabled: _selectedDate != null,
      onNext: () {
        ref.read(onboardingDataProvider.notifier).update((s) => {
          ...s,
          'last_period_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        });
        context.go('/onboarding/cycle-length');
      },
      content: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 60)),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _selectedDate != null ? AppColors.menstrualGradient : null,
                color: _selectedDate == null ? AppColors.surfaceVariant : null,
                borderRadius: BorderRadius.circular(20),
                border: _selectedDate == null
                    ? Border.all(color: AppColors.primaryLight, width: 2, style: BorderStyle.solid)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    _selectedDate != null ? '🌸' : '📅',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedDate != null
                        ? _fmt.format(_selectedDate!)
                        : 'Tap to select date',
                    style: AppTextStyles.headline3.copyWith(
                      color: _selectedDate != null ? Colors.white : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Your cycle predictions will start from this date. You can update it anytime.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
