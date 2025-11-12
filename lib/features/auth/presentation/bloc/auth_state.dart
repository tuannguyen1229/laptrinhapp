import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetRequested extends AuthState {
  final String resetCode;
  final String email;

  const PasswordResetRequested({
    required this.resetCode,
    required this.email,
  });

  @override
  List<Object?> get props => [resetCode, email];
}

class PasswordResetTokenVerified extends AuthState {
  final String token;

  const PasswordResetTokenVerified(this.token);

  @override
  List<Object?> get props => [token];
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}

class UsernameAvailabilityChecked extends AuthState {
  final bool isAvailable;
  final String username;

  const UsernameAvailabilityChecked({
    required this.isAvailable,
    required this.username,
  });

  @override
  List<Object?> get props => [isAvailable, username];
}

class EmailAvailabilityChecked extends AuthState {
  final bool isAvailable;
  final String email;

  const EmailAvailabilityChecked({
    required this.isAvailable,
    required this.email,
  });

  @override
  List<Object?> get props => [isAvailable, email];
}

class RegisterSuccess extends AuthState {
  const RegisterSuccess();
}
