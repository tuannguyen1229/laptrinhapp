import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<RequestPasswordResetEvent>(_onRequestPasswordReset);
    on<VerifyResetTokenEvent>(_onVerifyResetToken);
    on<ResetPasswordEvent>(_onResetPassword);
    on<CheckUsernameAvailableEvent>(_onCheckUsernameAvailable);
    on<CheckEmailAvailableEvent>(_onCheckEmailAvailable);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.getCurrentUser();

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.login(
      event.username,
      event.password,
      event.rememberMe,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.register(
      username: event.username,
      email: event.email,
      password: event.password,
      fullName: event.fullName,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(const RegisterSuccess()),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onRequestPasswordReset(
    RequestPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.requestPasswordReset(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (data) => emit(PasswordResetRequested(
        resetCode: data['token']!,
        email: data['email']!,
      )),
    );
  }

  Future<void> _onVerifyResetToken(
    VerifyResetTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.verifyResetToken(event.token);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (isValid) {
        if (isValid) {
          emit(PasswordResetTokenVerified(event.token));
        } else {
          emit(const AuthError('Mã xác thực không hợp lệ hoặc đã hết hạn'));
        }
      },
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.resetPassword(
      event.token,
      event.newPassword,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const PasswordResetSuccess()),
    );
  }

  Future<void> _onCheckUsernameAvailable(
    CheckUsernameAvailableEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.checkUsernameAvailable(event.username);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (isAvailable) => emit(UsernameAvailabilityChecked(
        isAvailable: isAvailable,
        username: event.username,
      )),
    );
  }

  Future<void> _onCheckEmailAvailable(
    CheckEmailAvailableEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.checkEmailAvailable(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (isAvailable) => emit(EmailAvailabilityChecked(
        isAvailable: isAvailable,
        email: event.email,
      )),
    );
  }
}
