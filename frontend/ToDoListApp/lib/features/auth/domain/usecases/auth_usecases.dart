import '../entities/user_profile_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repo);

  final AuthRepository _repo;

  Future<void> call({
    required String userName,
    required String email,
    required String password,
    required String fullName,
  }) {
    return _repo.register(
      userName: userName,
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}

class LoginUseCase {
  LoginUseCase(this._repo);

  final AuthRepository _repo;

  Future<String> call({
    required String account,
    required String password,
  }) {
    return _repo.login(account: account, password: password);
  }
}

class GetProfileUseCase {
  GetProfileUseCase(this._repo);

  final AuthRepository _repo;

  Future<UserProfileEntity> call() {
    return _repo.getProfile();
  }
}

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repo);

  final AuthRepository _repo;

  Future<UserProfileEntity> call({
    String? userName,
    String? fullName,
    String? avatarUrl,
  }) {
    return _repo.updateProfile(
      userName: userName,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}
