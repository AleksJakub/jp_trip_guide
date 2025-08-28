import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/local/hive_boxes.dart';
import '../../core/utils/web_cookies.dart';

class AuthService {
  static const String _keyUser = 'current_user';

  const AuthService();

  Box get _box => Hive.box(HiveBoxes.auth);
  Box get _users => Hive.box(HiveBoxes.users);

  bool get isSignedIn => _box.containsKey(_keyUser);

  Map<String, dynamic>? get currentUser {
    final dynamic data = _box.get(_keyUser);
    if (data is Map) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  Future<void> signOut() async {
    await _box.delete(_keyUser);
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (username.trim().isEmpty) return 'Username is required';
    if (!_isValidEmail(email)) return 'Enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != confirmPassword) return 'Passwords do not match';

    final String key = email.trim().toLowerCase();
    if (_users.containsKey(key)) return 'An account with this email already exists';

    final String salt = _generateSalt();
    final String hash = _hashPassword(password, salt);

    final Map<String, dynamic> record = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'username': username.trim(),
      'email': key,
      'salt': salt,
      'passwordHash': hash,
      'bio': '',
      'photoPath': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _users.put(key, record);

    await _box.put(_keyUser, {
      'username': record['username'],
      'email': record['email'],
      'bio': record['bio'],
      'photoPath': record['photoPath'],
    });
    await setPersistentFlag('signed_in_email', key);
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final String key = email.trim().toLowerCase();
    final dynamic raw = _users.get(key);
    if (raw == null) return 'No account found. Please register first.';
    final Map<String, dynamic> record = Map<String, dynamic>.from(raw as Map);
    final String salt = record['salt'] as String;
    final String expected = record['passwordHash'] as String;
    final String actual = _hashPassword(password, salt);
    if (actual != expected) return 'Incorrect password';

    await _box.put(_keyUser, {
      'username': record['username'],
      'email': record['email'],
      'bio': record['bio'],
      'photoPath': record['photoPath'],
    });
    await setPersistentFlag('signed_in_email', key);
    return null;
  }

  bool _isValidEmail(String email) {
    final RegExp re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(email.trim());
  }

  Future<void> updateProfile({
    String? username,
    String? email,
    String? bio,
    String? photoPath,
  }) async {
    final Map<String, dynamic> session = currentUser ?? <String, dynamic>{};
    final String originalKey = (session['email'] as String?)?.toLowerCase() ?? '';
    if (username != null) session['username'] = username.trim();
    if (email != null && _isValidEmail(email)) session['email'] = email.trim().toLowerCase();
    if (bio != null) session['bio'] = bio;
    if (photoPath != null) session['photoPath'] = photoPath;
    await _box.put(_keyUser, session);

    if (originalKey.isNotEmpty && _users.containsKey(originalKey)) {
      final Map<String, dynamic> record = Map<String, dynamic>.from(_users.get(originalKey) as Map);
      record['username'] = session['username'];
      record['bio'] = session['bio'];
      record['photoPath'] = session['photoPath'];
      if (email != null && _isValidEmail(email)) {
        final String newKey = session['email'] as String;
        record['email'] = newKey;
        await _users.delete(originalKey);
        await _users.put(newKey, record);
      } else {
        await _users.put(originalKey, record);
      }
    }
  }

  String _generateSalt({int length = 16}) {
    final Random rng = Random.secure();
    final List<int> bytes = List<int>.generate(length, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final List<int> bytes = utf8.encode('$salt:$password');
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }
}


