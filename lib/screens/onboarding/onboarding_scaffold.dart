import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class OnboardingScaffold extends StatelessWidget {
  final String stepText;
  final String title;
  final String? subtitle;
  final Widget content;
  final String? nextRoute;
  final VoidCallback? onNext;
  final bool nextEnabled;

  const OnboardingScaffold({
    super.key,
    required this.stepText,
    required this.title,
    this.subtitle,
    required this.content,
    this.nextRoute,
    this.onNext,
    this.nextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  if (context.canPop())
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 4),
                  Text(stepText, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headline1),
                    if (subtitle != null) ...[
                      const SizedBox(height: 10),
                      Text(subtitle!, style: AppTextStyles.body2),
                    ],
                    const SizedBox(height: 40),
                    content,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: PrimaryButton(
                text: AppStrings.continueText,
                onPressed: nextEnabled
                    ? () {
                        if (onNext != null) {
                          onNext!();
                        } else if (nextRoute != null) {
                          context.go(nextRoute!);
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
