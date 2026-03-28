import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../di/providers.dart';

class AuthState {
  const AuthState({
    this.loading = false,
    this.error,
    this.token,
    this.profile,
  });

  final bool loading;
  final String? error;
  final String? token;
  final UserProfileEntity? profile;

  AuthState copyWith({
    bool? loading,
    String? error,
    String? token,
    UserProfileEntity? profile,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error,
      token: token ?? this.token,
      profile: profile ?? this.profile,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._login,
    this._register,
    this._getProfile,
    this._updateProfile,
  ) : super(const AuthState());

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  Future<bool> login({required String account, required String password}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _login(account: account, password: password);
      final profile = await _getProfile();
      state = state.copyWith(loading: false, token: token, profile: profile);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String userName,
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _register(
        userName: userName,
        email: email,
        password: password,
        fullName: fullName,
      );
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await _getProfile();
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> updateProfile({
    String? userName,
    String? fullName,
    String? avatarUrl,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final profile = await _updateProfile(
        userName: userName,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(loading: false, profile: profile);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(loginUseCaseProvider),
    ref.read(registerUseCaseProvider),
    ref.read(getProfileUseCaseProvider),
    ref.read(updateProfileUseCaseProvider),
  );
});
