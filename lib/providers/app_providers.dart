import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/cycle_model.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool onboardingRequired;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.onboardingRequired = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? onboardingRequired,
    String? error,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    onboardingRequired: onboardingRequired ?? this.onboardingRequired,
    error: error ?? this.error,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api = ApiService();

  AuthNotifier() : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _api.getAccessToken();
    if (token != null) {
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<String?> requestOtp(String mobileNumber) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final response = await _api.requestOtp(mobileNumber);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return response.data['otp'] as String?;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(String mobileNumber, String code) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final response = await _api.verifyOtp(mobileNumber, code);
      final data = response.data;

      await _api.saveTokens(
        access: data['tokens']['access'],
        refresh: data['tokens']['refresh'],
      );

      final user = UserModel.fromJson(data['user']);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        onboardingRequired: data['onboarding_required'] ?? true,
      );
      return data;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: 'Invalid OTP. Please try again.');
      return null;
    }
  }

  Future<void> signOut() async {
    await _api.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);

// ─── Profile Provider ─────────────────────────────────────────────────────────
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ApiService _api = ApiService();

  ProfileNotifier() : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      state = const AsyncValue.loading();
      final response = await _api.getProfile();
      state = AsyncValue.data(UserProfile.fromJson(response.data));
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<String?> saveProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.updateProfile(data);
      state = AsyncValue.data(UserProfile.fromJson(response.data));
      return null;
    } catch (e) {
      // Extract meaningful error from Dio or other exceptions
      try {
        final dynamic err = e;
        final resData = err.response?.data;
        if (resData is Map && resData.containsKey('detail')) {
          return resData['detail'].toString();
        }
        final msg = err.response?.statusMessage ?? err.message;
        if (msg != null) return msg.toString();
      } catch (_) {}
      return e.toString();
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>(
  (_) => ProfileNotifier(),
);

// ─── Prediction Provider ──────────────────────────────────────────────────────
final predictionProvider = FutureProvider<PredictionData?>((ref) async {
  try {
    final response = await ApiService().getPredictions();
    return PredictionData.fromJson(response.data);
  } catch (_) {
    return null;
  }
});

// ─── Guidance Provider ────────────────────────────────────────────────────────
final guidanceProvider = FutureProvider<GuidanceData?>((ref) async {
  try {
    final lang = ref.watch(localeProvider).languageCode;
    final response = await ApiService().getTodayGuidance(lang: lang);
    return GuidanceData.fromJson(response.data);
  } catch (_) {
    return null;
  }
});

// ─── Cycles Provider ──────────────────────────────────────────────────────────
final cyclesProvider = FutureProvider<List<CycleLog>>((ref) async {
  try {
    final response = await ApiService().getCycles();
    return (response.data as List).map((c) => CycleLog.fromJson(c)).toList();
  } catch (_) {
    return [];
  }
});

// ─── Cycle History Provider ───────────────────────────────────────────────────
final cycleHistoryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final response = await ApiService().getCycleHistory();
    return Map<String, dynamic>.from(response.data);
  } catch (_) {
    return {};
  }
});

// ─── Theme Provider ───────────────────────────────────────────────────────────
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light

// ─── Locale Provider ──────────────────────────────────────────────────────────
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

// ─── Onboarding Data Provider ─────────────────────────────────────────────────
final onboardingDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// ─── Notification Controller ──────────────────────────────────────────────────
final notificationSyncProvider = Provider<void>((ref) {
  final profileAsync = ref.watch(profileProvider);
  final predictionAsync = ref.watch(predictionProvider);

  profileAsync.whenData((profile) async {
    final service = NotificationService();
    
    if (profile == null || !profile.notificationsEnabled) {
      await service.cancelAllReminders();
      return;
    }
    
    predictionAsync.whenData((prediction) async {
      if (prediction == null) return;
      
      await service.cancelAllReminders();
      
      // Schedule Period Reminder (1 day before)
      final periodStart = DateTime.parse(prediction.nextPeriodDate);
      final periodReminderDate = periodStart.subtract(const Duration(days: 1)).add(const Duration(hours: 9)); // 9 AM
      
      if (periodReminderDate.isAfter(DateTime.now())) {
        await service.scheduleReminder(
          id: 1,
          title: 'Period is coming soon 🌸',
          body: 'Your next period is predicted to start tomorrow. Make sure you are prepared!',
          scheduledDate: periodReminderDate,
        );
      }
      
      // Schedule Ovulation Reminder (on the day)
      final ovulationDay = DateTime.parse(prediction.ovulationDate);
      final ovulationReminderDate = ovulationDay.add(const Duration(hours: 9)); // 9 AM
      
      if (ovulationReminderDate.isAfter(DateTime.now())) {
        await service.scheduleReminder(
          id: 2,
          title: 'Peak fertility day! ✨',
          body: 'Today is your predicted ovulation day. Log your symptoms to keep your predictions accurate.',
          scheduledDate: ovulationReminderDate,
        );
      }
    });
  });
});
