import 'hive_helper.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';

  Future<String?> register(String name, String email, String password) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) return 'Nama tidak boleh kosong.';
    if (!_isValidEmail(cleanEmail)) return 'Format email tidak valid.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (HiveHelper.usersBox.containsKey(cleanEmail)) {
      return 'Email sudah terdaftar.';
    }

    await HiveHelper.usersBox.put(cleanEmail, {
      'name': cleanName,
      'email': cleanEmail,
      'password': password,
    });
    return null;
  }

  Future<String?> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!_isValidEmail(cleanEmail)) return 'Format email tidak valid.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';

    final user = HiveHelper.usersBox.get(cleanEmail);
    if (user == null) return 'Email belum terdaftar.';
    if (user['password'] != password) return 'Password salah.';

    final settings = HiveHelper.settingsBox;
    await settings.put(_keyIsLoggedIn, true);
    await settings.put(_keyUserEmail, cleanEmail);
    await settings.put(_keyUserName, user['name'] as String);
    return null;
  }

  Future<void> logout() async {
    final settings = HiveHelper.settingsBox;
    await settings.delete(_keyIsLoggedIn);
    await settings.delete(_keyUserEmail);
    await settings.delete(_keyUserName);
  }

  Future<bool> isLoggedIn() async {
    return HiveHelper.settingsBox.get(_keyIsLoggedIn) as bool? ?? false;
  }

  Future<String?> getUserEmail() async {
    return HiveHelper.settingsBox.get(_keyUserEmail) as String?;
  }

  Future<String?> getUserName() async {
    return HiveHelper.settingsBox.get(_keyUserName) as String?;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }
}
