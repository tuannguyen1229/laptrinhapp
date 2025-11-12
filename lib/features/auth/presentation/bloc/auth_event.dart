import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginEvent({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [username, password, rememberMe];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String fullName;

  const RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [username, email, password, fullName];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class RequestPasswordResetEvent extends AuthEvent {
  final String email;

  const RequestPasswordResetEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyResetTokenEvent extends AuthEvent {
  final String token;

  const VerifyResetTokenEvent(this.token);

  @override
  List<Object?> get props => [token];
}

class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordEvent({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}

class CheckUsernameAvailableEvent extends AuthEvent {
  final String username;

  const CheckUsernameAvailableEvent(this.username);

  @override
  List<Object?> get props => [username];
}

class CheckEmailAvailableEvent extends AuthEvent {
  final String email;

  const CheckEmailAvailableEvent(this.email);

  @override
  List<Object?> get props => [email];
}
