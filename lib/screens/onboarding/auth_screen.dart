import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String phone) {
    phone = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (!phone.startsWith('+')) {
      phone = '+88$phone';
    }
    return phone;
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      setState(() => _phoneError = 'Please enter your mobile number.');
      return;
    }
    if (rawPhone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
      setState(() => _phoneError = 'Please enter a valid mobile number.');
      return;
    }
    final phone = _normalizePhone(rawPhone);

    setState(() => _phoneError = null);
    final notifier = ref.read(authProvider.notifier);
    final otp = await notifier.requestOtp(phone);

    if (otp != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔑 Development Mode: Your OTP is $otp'),
          duration: const Duration(seconds: 15),
          backgroundColor: AppColors.primaryDark,
          action: SnackBarAction(
            label: 'Copy',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      context.push('/otp', extra: phone);
    } else if (mounted) {
      final err = ref.read(authProvider).error ?? 'Failed to send OTP. Please try again.';
      setState(() => _phoneError = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Logo
              const Text('🌸', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: AppTextStyles.display.copyWith(
                  foreground: Paint()
                    ..shader = AppColors.primaryGradient.createShader(
                      const Rect.fromLTWH(0, 0, 200, 60),
                    ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.appTagline,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle2,
              ),
              const SizedBox(height: 56),

              // Phone number entry
              Text(context.l10n.enterMobileNumber, style: AppTextStyles.headline3),
              const SizedBox(height: 8),
              Text(
                context.l10n.enterMobileNumber, // Temporary subtitle
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.body1,
                decoration: InputDecoration(
                  hintText: context.l10n.mobileHint,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('🇧🇩', style: TextStyle(fontSize: 20)),
                  ),
                  errorText: _phoneError,
                ),
                onChanged: (_) => setState(() => _phoneError = null),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: context.l10n.sendOTP,
                onPressed: isLoading ? null : _sendOtp,
                isLoading: isLoading,
              ),
              const SizedBox(height: 48),
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy. Your health data is encrypted and stays private.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
