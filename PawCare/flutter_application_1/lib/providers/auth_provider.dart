// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
// import 'package:http/http.dart' as http; // ŞİMDİLİK YORUMA ALINDI
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ŞİMDİLİK YORUMA ALINDI

enum AuthStatus { uninitialized, authenticating, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  // --- GEÇİCİ: Başlangıçta authenticated olsun ---
  AuthStatus _status = AuthStatus.authenticated;
  String? _token = "dummy_dev_token_ui_test"; // API'ye istek gitmeyecek
  // --- GEÇİCİ SONU ---

  // final String _baseUrl = "http://10.0.2.2:5000/api"; // Şimdilik kullanılmayacak
  String get baseUrl => "http://10.0.2.2:5000/api"; // PetProvider hala buna ihtiyaç duyabilir

  // final _storage = const FlutterSecureStorage(); // Şimdilik kullanılmayacak

  AuthStatus get status => _status;
  String? get token => _token;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  AuthProvider() {
    debugPrint("AuthProvider: UI Test Modu - Durum başlangıçta: $_status");
    // _checkInitialAuthStatus(); // API isteği yok
  }

  Future<void> _checkInitialAuthStatus() async {
    debugPrint("AuthProvider: _checkInitialAuthStatus çağrıldı (UI Test Modu - işlem yok).");
    // Şimdilik hiçbir şey yapma, _status constructor'da ayarlandı.
  }

  Future<void> login(String emailOrUsername, String password) async {
    debugPrint("AuthProvider: login çağrıldı (UI Test Modu - her zaman başarılı).");
    _status = AuthStatus.authenticating;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _token = "simulated_login_token_ui_test";
    // await _storage.write(key: 'authToken', value: _token); // Şimdilik saklama
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String username) async {
    debugPrint("AuthProvider: signUp çağrıldı (UI Test Modu - login'e yönlendirir).");
    _status = AuthStatus.authenticating;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _status = AuthStatus.unauthenticated; // Kayıt sonrası giriş yapsın diye
    notifyListeners();
  }

  Future<void> logout() async {
    debugPrint("AuthProvider: logout çağrıldı (UI Test Modu).");
    _token = null;
    // await _storage.delete(key: 'authToken'); // Şimdilik silme
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}