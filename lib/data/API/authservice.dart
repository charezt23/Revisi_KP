import 'dart:convert';
import 'package:flutter_application_1/data/API/BaseURL.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';

class AuthService {
  // Secure storage instance
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Login method
  static Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(responseData);

      print('Waiting Login');
      if (loginResponse.success && loginResponse.data != null) {
        await _saveUserData(loginResponse.data!);
        print('Login successful, user data saved.');
      }

      return loginResponse;
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // Simpan data user ke secure storage
  static Future<void> _saveUserData(LoginData data) async {
    await _secureStorage.write(key: _tokenKey, value: data.token);
    await _secureStorage.write(key: _userIdKey, value: data.user.id.toString());
    await _secureStorage.write(key: _userNameKey, value: data.user.name);
    await _secureStorage.write(key: _userEmailKey, value: data.user.email);
  }

  // Ambil token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Ambil user ID
  static Future<int?> getUserId() async {
    final userIdString = await _secureStorage.read(key: _userIdKey);
    return userIdString != null ? int.tryParse(userIdString) : null;
  }

  // Ambil data user lengkap
  static Future<User?> getCurrentUser() async {
    final userId = await getUserId();
    final name = await _secureStorage.read(key: _userNameKey);
    final email = await _secureStorage.read(key: _userEmailKey);

    if (userId != null && name != null && email != null) {
      return User(id: userId, name: name, email: email);
    }
    return null;
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout - hapus semua data
  static Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/logout'),
        headers: await getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        await _secureStorage.delete(key: _tokenKey);
        await _secureStorage.delete(key: _userIdKey);
        await _secureStorage.delete(key: _userNameKey);
        await _secureStorage.delete(key: _userEmailKey);
        print('Logout successful.');
      } else {
        throw Exception('Logout failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Clear all secure storage (untuk keperluan debugging)
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  // Method untuk API calls yang memerlukan authentication
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Contoh method untuk refresh token (opsional)
  static Future<bool> refreshToken() async {
    try {
      final currentToken = await getToken();
      if (currentToken == null) return false;

      final response = await http.post(
        Uri.parse('$base_url/refresh'),
        headers: await getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['token'] != null) {
          await _secureStorage.write(
            key: _tokenKey,
            value: responseData['token'],
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$base_url/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final Map<String, dynamic> responseData = jsonDecode(response.body);
    print('Response Data: $responseData');
    if (response.statusCode == 201) {
      final registerResponse = responseData['success'] as bool;
      return registerResponse;
    } else {
      if (responseData['success'] == false) {
        // Jika ada pesan error dari server
        final errorMessage = responseData['errors'] ?? 'Unknown error';
        throw Exception('$errorMessage');
      } else {
        final errorMessage = responseData['errors'] ?? 'Unknown error';
        print('Registration failed: $errorMessage');
        throw Exception('$errorMessage');
      }
    }
  }
}
