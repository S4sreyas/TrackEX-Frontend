import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// (Optional) Custom exception for auth errors.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// AuthService encapsulates all authentication and token management.
class AuthService {
  // Base URL for your authentication endpoints.
  final String baseUrl = 'http://10.0.2.2:8000/api/accounts';
  
  // Create an instance of secure storage.
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Key names for storing tokens.
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Registers a new user.
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String password2,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'email': email,
        'username': username,
        'password': password,
        'password2': password2,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await storage.write(key: _accessTokenKey, value: data['access']);
      await storage.write(key: _refreshTokenKey, value: data['refresh']);
      return data['user'];
    } else {
      final errorBody = json.decode(response.body);
      // You can throw a custom exception here if desired.
      throw AuthException('Registration failed: ${errorBody.toString()}');
    }
  }

  /// Logs in an existing user.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: _accessTokenKey, value: data['access']);
      await storage.write(key: _refreshTokenKey, value: data['refresh']);
      return data['user'];
    } else {
      if (response.statusCode == 401) {
        throw AuthException('Invalid email or password');
      }
      throw AuthException('Login failed');
    }
  }

  /// Logs out the user by clearing stored tokens.
  Future<void> logout() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }

  /// Retrieves the stored access token.
  Future<String?> getAccessToken() async {
    return await storage.read(key: _accessTokenKey);
  }
}
