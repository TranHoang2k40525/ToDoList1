import '../entities/user_profile_entity.dart';

abstract class AuthRepository {
  Future<void> register({
    required String userName,
    required String email,
    required String password,
    required String fullName,
  });

  Future<String> login({
    required String account,
    required String password,
  });

  Future<UserProfileEntity> getProfile();

  Future<UserProfileEntity> updateProfile({
    String? userName,
    String? fullName,
    String? avatarUrl,
  });
}
