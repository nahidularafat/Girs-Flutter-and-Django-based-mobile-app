import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppStrings.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _readToken('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _readToken('access_token');
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (_) {}
          }
        }
        return handler.next(error);
      },
    ));
  }

  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  // ─── Token helpers (SharedPreferences — works on Web) ─────────────────────
  static Future<String?> _readToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> _writeToken(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> _deleteToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _readToken('refresh_token');
      if (refreshToken == null) return false;
      final response = await _dio.post('auth/token/refresh/', data: {'refresh': refreshToken});
      await _writeToken('access_token', response.data['access']);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────
  Future<Response> requestOtp(String mobileNumber) =>
      _dio.post('auth/otp/request/', data: {'mobile_number': mobileNumber});

  Future<Response> verifyOtp(String mobileNumber, String code) =>
      _dio.post('auth/otp/verify/', data: {'mobile_number': mobileNumber, 'code': code});

  Future<Response> googleLogin(String idToken) =>
      _dio.post('auth/google/', data: {'id_token': idToken});

  // ─── Profile ──────────────────────────────────────────────────────────────
  Future<Response> getProfile() => _dio.get('profile/');
  Future<Response> updateProfile(Map<String, dynamic> data) =>
      _dio.put('profile/', data: data);

  // ─── Cycles ───────────────────────────────────────────────────────────────
  Future<Response> getCycles() => _dio.get('cycles/');
  Future<Response> logCycle(Map<String, dynamic> data) =>
      _dio.post('cycles/', data: data);
  Future<Response> updateCycle(int id, Map<String, dynamic> data) =>
      _dio.patch('cycles/$id/', data: data);
  Future<Response> logSymptom(int cycleId, Map<String, dynamic> data) =>
      _dio.post('cycles/$cycleId/symptoms/', data: data);

  // ─── Predictions ──────────────────────────────────────────────────────────
  Future<Response> getPredictions() => _dio.get('cycles/predictions/');
  Future<Response> getCycleHistory() => _dio.get('cycles/history/');

  // ─── Guidance ─────────────────────────────────────────────────────────────
  Future<Response> getTodayGuidance({String lang = 'en'}) => 
      _dio.get('guidance/today/', queryParameters: {'lang': lang});

  // ─── Token storage helpers ────────────────────────────────────────────────
  Future<void> saveTokens({required String access, required String refresh}) async {
    await _writeToken('access_token', access);
    await _writeToken('refresh_token', refresh);
  }

  Future<void> clearTokens() async {
    await _deleteToken('access_token');
    await _deleteToken('refresh_token');
  }

  Future<String?> getAccessToken() => _readToken('access_token');
}
