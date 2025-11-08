import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

enum AdminRole { admin, secretary }

class AuthService {
  static const _adminPassKey = 'admin_master_pass';
  static const _secretaryPassKey = 'secretary_pass';

  static const String _defaultAdminPass = '2468';
  static const String _defaultSecretaryPass = '1357';

  static Future<AdminRole?> loginAdmin(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final admin = prefs.getString(_adminPassKey) ?? _defaultAdminPass;
    final sec = prefs.getString(_secretaryPassKey) ?? _defaultSecretaryPass;
    if (password == admin) return AdminRole.admin;
    if (password == sec) return AdminRole.secretary;
    return null;
  }

  static Future<void> setAdminPassword(String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminPassKey, pass);
  }

  static Future<void> setSecretaryPassword(String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_secretaryPassKey, pass);
  }

  static Future<void> setUserPassword(String phone, String pass) async {
    await FirestoreService.upsertUser(phone: phone, password: pass);
  }

  static Future<bool> loginUser(String phone, String pass) async {
    final u = await FirestoreService.getUser(phone);
    if (u == null) return false;
    return (u['password'] ?? '') == pass;
  }
}
