import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';

@injectable
class PasswordService {
  /// Hash password với salt
  String hashPassword(String password) {
    final salt = _generateSalt();
    final hash = _hashWithSalt(password, salt);
    return '$salt:$hash';
  }

  /// Verify password
  bool verifyPassword(String password, String hashedPassword) {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final hash = parts[1];
      final newHash = _hashWithSalt(password, salt);

      return hash == newHash;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  /// Generate random salt
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  /// Hash password with salt using SHA-256
  String _hashWithSalt(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate password strength
  bool isPasswordStrong(String password) {
    if (password.length < 6) return false;
    
    // Check for at least one letter and one number
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    
    return hasLetter && hasNumber;
  }

  /// Get password strength message
  String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!password.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ cái';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }
    return '';
  }

  /// Hash password using SHA-256 only (legacy, for backward compatibility)
  String hashPasswordLegacy(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
