import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService _authService;

  ProfileBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final pasien = await _authService.getCurrentUser();
      
      if (pasien != null) {
        emit(ProfileLoaded(pasien: pasien));
      } else {
        emit(const ProfileError(message: 'Data pasien tidak ditemukan'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // Save current state
    final currentState = state;
    
    emit(const ProfileLoading());

    try {
      final result = await _authService.changePassword(event.request);
      
      if (result['success'] == true) {
        emit(PasswordChangeSuccess(message: result['message'] as String));
        // Restore profile state after success
        if (currentState is ProfileLoaded) {
          emit(currentState);
        }
      } else {
        emit(ProfileError(message: result['message'] as String));
        // Restore profile state after error
        if (currentState is ProfileLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
      // Restore profile state after error
      if (currentState is ProfileLoaded) {
        emit(currentState);
      }
    }
  }
}
