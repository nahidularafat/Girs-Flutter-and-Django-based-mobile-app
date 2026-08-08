import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/primary_button.dart';


class OtpScreen extends ConsumerStatefulWidget {
  final String mobileNumber;
  const OtpScreen({super.key, required this.mobileNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  String? _error;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() { _resendCountdown = 30; _canResend = false; });
    Future.delayed(const Duration(seconds: 1), _tick);
  }

  void _tick() {
    if (!mounted) return;
    if (_resendCountdown > 0) {
      setState(() => _resendCountdown--);
      Future.delayed(const Duration(seconds: 1), _tick);
    } else {
      setState(() => _canResend = true);
    }
  }

  String get _otp => _otpController.text.trim();

  Future<void> _verify() async {
    if (_otp.length < 6) {
      setState(() => _error = 'Please enter the complete 6-digit code.');
      return;
    }
    setState(() => _error = null);
    final result = await ref.read(authProvider.notifier).verifyOtp(widget.mobileNumber, _otp);
    if (result != null && mounted) {
      ref.read(onboardingDataProvider.notifier).update((s) => {...s, 'mobile_number': widget.mobileNumber});
      final onboarding = result['onboarding_required'] ?? true;
      if (onboarding) {
        context.go('/onboarding/location');
      } else {
        context.go('/home');
      }
    } else if (mounted) {
      setState(() => _error = 'Invalid code. Please try again.');
      _otpController.clear();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('🔐', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
              const SizedBox(height: 24),
              Text(AppStrings.enterOTP, style: AppTextStyles.headline2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                '${AppStrings.otpSentTo} ${widget.mobileNumber}',
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Single centered OTP input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _otpController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline1.copyWith(
                    letterSpacing: 16,
                    color: AppColors.primaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••••',
                    hintStyle: AppTextStyles.headline1.copyWith(
                      letterSpacing: 16,
                      color: AppColors.textHint,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onChanged: (val) {
                    setState(() => _error = null);
                  },
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                text: AppStrings.verifyOTP,
                onPressed: isLoading ? null : _verify,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).requestOtp(widget.mobileNumber);
                          _startResendTimer();
                        },
                        child: Text(AppStrings.resendOTP,
                            style: AppTextStyles.subtitle2.copyWith(color: AppColors.primary)),
                      )
                    : Text(
                        'Resend code in ${_resendCountdown}s',
                        style: AppTextStyles.caption,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
