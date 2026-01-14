import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // LOGIN
  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final jsonBody = json.encode(request.toJson());

      final response = await http
          .post(
            Uri.parse('${ApiConfg.baseurl}${ApiConfg.login}'),
            headers: ApiConfg.headers(),
            body: jsonBody,
          )
          .timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final loginResponse = LoginResponse.fromJson(jsonData);

        // Stocker le token et les données utilisateur de manière sécurisée
        final token = await generateToken();

        await saveToken(token);
        await saveUser(loginResponse.user);

        return loginResponse;
      } else {
        throw Exception('Échec de la connexion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Genrate token from backend
  Future<String> generateToken() async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfg.baseurl}${ApiConfg.generateToken}'),
            headers: ApiConfg.headers(),
          )
          .timeout(ApiConfg.apiTimeout);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Échec de la génération du token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de génération du token: $e');
    }
  }

  //Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  //Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Save User
  Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: json.encode(user.toJson()));
  }

  // Get User
  Future<User?> getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      final jsonData = json.decode(userData);
      return User.fromJson(jsonData);
    }
    return null;
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> logout() async {
    await clearAuth();
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
