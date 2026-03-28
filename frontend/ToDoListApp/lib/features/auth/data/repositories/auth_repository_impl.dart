import '../../../../core/local/local_cache.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._cache);

  final AuthRemoteDataSource _remote;
  final LocalCache _cache;

  @override
  Future<void> register({
    required String userName,
    required String email,
    required String password,
    required String fullName,
  }) {
    return _remote.register(
      userName: userName,
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  @override
  Future<String> login({required String account, required String password}) async {
    final token = await _remote.login(account: account, password: password);
    await _cache.saveToken(token);
    return token;
  }

  @override
  Future<UserProfileEntity> getProfile() async {
    try {
      final profile = await _remote.getProfile();
      await _cache.saveProfileCache(profile.toJson());
      return profile.toEntity();
    } catch (_) {
      final cached = await _cache.getProfileCache();
      if (cached != null) {
        return UserProfileEntity(
          id: (cached['id'] ?? '').toString(),
          userName: (cached['userName'] ?? '').toString(),
          email: (cached['email'] ?? '').toString(),
          fullName: (cached['fullName'] ?? '').toString(),
          avatarUrl: cached['avatarUrl']?.toString(),
          createdAt: DateTime.tryParse((cached['createdAt'] ?? '').toString()) ??
              DateTime.fromMillisecondsSinceEpoch(0),
        );
      }
      rethrow;
    }
  }

  @override
  Future<UserProfileEntity> updateProfile({
    String? userName,
    String? fullName,
    String? avatarUrl,
  }) async {
    final profile = await _remote.updateProfile(
      userName: userName,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
    await _cache.saveProfileCache(profile.toJson());
    return profile.toEntity();
  }
}
