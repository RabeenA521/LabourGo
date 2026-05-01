import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ── Change this to your Mac's IP when testing on real device
  // Run "ifconfig | grep inet" in terminal to find your IP. 
  // Current IP is 192.168.1.105. For local web testing, 127.0.0.1 works.
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ── Save token locally ───────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // ── Headers ──────────────────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static const Map<String, String> _publicHeaders = {
    'Content-Type': 'application/json',
  };

  // ── AUTH ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: _publicHeaders,
      body: jsonEncode({
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: _publicHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> socialLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? email,
    String? fullName,
    String role = 'customer',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/social-login/'),
      headers: _publicHeaders,
      body: jsonEncode({
        'provider': provider,
        'id_token': idToken,
        'access_token': accessToken,
        'email': email,
        'full_name': fullName,
        'role': role,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    // In a real app this would PUT/PATCH to a backend endpoint.
    // For now we mock a successful response.
    await Future.delayed(const Duration(seconds: 1));
    return {'status': 'success', 'message': 'Profile updated locally.'};
  }

  // ── BOOKINGS ─────────────────────────────────────────────

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/categories/'),
      headers: _publicHeaders,
    );
    return jsonDecode(response.body);
  }

  // Get all providers (for booking creation)
  static Future<List<dynamic>> getProviders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/providers/'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createBooking({
    required int providerId,
    required int categoryId,
    required String description,
    required String locationAddress,
    required String scheduledDate,
    required String scheduledTime,
    required String priceOffered,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/create/'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'provider_id': providerId,
        'category_id': categoryId,
        'description': description,
        'location_address': locationAddress,
        'scheduled_date': scheduledDate,
        'scheduled_time': scheduledTime,
        'price_offered': priceOffered,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getMyBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/my-bookings/'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ── PAYMENTS ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> makePayment({
    required int bookingId,
    required String amount,
    required String method,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/pay/'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'booking_id': bookingId,
        'amount': amount,
        'method': method,
      }),
    );
    return jsonDecode(response.body);
  }

  // ── REVIEWS ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> submitReview({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews/create/'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment,
      }),
    );
    return jsonDecode(response.body);
  }
}
