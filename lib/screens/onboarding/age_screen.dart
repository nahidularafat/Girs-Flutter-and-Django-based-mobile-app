import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import 'onboarding_scaffold.dart';


class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key});
  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> {
  final _ageController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final age = int.tryParse(_ageController.text);
    return age != null && age >= 13 && age <= 60;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepText: 'STEP 2 OF 6',
      title: AppStrings.yourAge,
      subtitle: AppStrings.ageSubtitle,
      nextEnabled: _isValid,
      onNext: () {
        final age = int.tryParse(_ageController.text);
        if (age == null || age < 13) {
          setState(() => _error = 'You must be at least 13 years old.');
          return;
        }
        ref.read(onboardingDataProvider.notifier).update((s) => {...s, 'age': age});
        context.go('/onboarding/marital');
      },
      content: Column(
        children: [
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            maxLength: 3,
            style: AppTextStyles.display.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '25',
              counterText: '',
              errorText: _error,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (v) {
              setState(() => _error = null);
              final age = int.tryParse(v);
              if (age != null && age < 13) {
                setState(() => _error = 'Must be at least 13 years old.');
              }
            },
          ),
          const SizedBox(height: 16),
          Text('years old', style: AppTextStyles.subtitle2),
          if (_isValid && int.parse(_ageController.text) < 18) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('👩‍👧', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Parental guidance recommended for users under 18.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
