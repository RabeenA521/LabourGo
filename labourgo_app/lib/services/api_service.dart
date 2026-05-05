import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // =========================
  // GET Providers
  // =========================
  static Future fetchProviders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/providers/'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load providers (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>?> findProviderByEmailPhone(
    String email,
    String phone,
  ) async {
    final providers = await fetchProviders();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (providers is! List) {
      return null;
    }

    for (final item in providers) {
      if (item is Map<String, dynamic>) {
        final providerEmail =
            (item['email'] ?? '').toString().trim().toLowerCase();
        final providerPhone =
            (item['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');

        if (providerEmail == normalizedEmail &&
            providerPhone == normalizedPhone) {
          return item;
        }
      }
    }

    return null;
  }

  // =========================
  // CREATE Provider
  // =========================
  static Future<void> createProvider(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/providers/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create provider");
    }
  }

  // =========================
  // PROFILE
  // =========================
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse("$baseUrl/providers/1/"),
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load profile (${response.statusCode}).',
      );
    }
    if (response.body.isEmpty) {
      throw Exception("Empty response from server");
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/providers/1/"),
      headers: const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update profile");
    }
  }

  // =========================
  // LOGIN
  // =========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _postJson('/auth/login/', {
      'email': email,
      'password': password,
    });
  }

  // =========================
  // REGISTER
  // =========================
  static Future<Map<String, dynamic>> register({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    return _postJson('/auth/register/', {
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'password': password,
    });
  }

  // =========================
  // SOCIAL LOGIN (placeholder)
  // =========================
  static Future<Map<String, dynamic>> socialLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? email,
    String? fullName,
  }) async {
    return {
      'error': 'Social login is not configured yet.'
    };
  }

  // =========================
  // COMMON POST METHOD
  // =========================
  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: const {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.body.isEmpty) {
      return {'error': 'Empty response from server.'};
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'error': 'Unexpected response from server.'};
  }
}