import 'dart:convert';
import 'dart:math';
import 'package:injectable/injectable.dart';

@injectable
class TokenService {
  /// Generate random token for password reset
  String generateResetToken() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Generate 6-digit code for password reset
  String generateResetCode() {
    final random = Random.secure();
    final code = random.nextInt(900000) + 100000; // 100000 to 999999
    return code.toString();
  }

  /// Check if token is expired
  bool isTokenExpired(DateTime expiresAt) {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Get token expiry time (15 minutes from now)
  DateTime getTokenExpiry() {
    return DateTime.now().add(const Duration(minutes: 15));
  }
}
