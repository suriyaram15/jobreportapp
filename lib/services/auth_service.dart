import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _sessionKey = 'session_token';
  static const String _loginTimeKey = 'login_time';
  static const String _emailKey = 'user_email';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey) != null;
  }

  Future<void> login(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, token);
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
    await prefs.setString(_emailKey, email);
  }

  Future<DateTime?> getLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeString = prefs.getString(_loginTimeKey);
    if (loginTimeString != null) {
      return DateTime.parse(loginTimeString);
    }
    return null;
  }
  
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_loginTimeKey);
    // We keep the email for the "Remember Me" feature
  }
}
