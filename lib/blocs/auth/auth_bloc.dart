import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/pasien.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final request = LoginRequest(
      noRm: event.noRm,
      password: event.password,
    );

    final result = await _authService.login(request);

    if (result['success'] == true) {
      emit(AuthAuthenticated(
        pasien: result['pasien'] as Pasien,
        token: result['token'] as String,
      ));
    } else {
      emit(AuthError(message: result['message'] as String));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isAuthenticated = await _authService.isAuthenticated();

    if (isAuthenticated) {
      final pasien = await _authService.getCurrentUser();
      if (pasien != null) {
        emit(AuthAuthenticated(
          pasien: pasien,
          token: '', // Token already stored
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
