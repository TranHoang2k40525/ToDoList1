import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/user_profile_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> register({
    required String userName,
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _client.dio.post(
      '/api/user/register',
      data: {
        'userName': userName,
        'email': email,
        'password': password,
        'fullName': fullName,
      },
    );
  }

  Future<String> login({
    required String account,
    required String password,
  }) async {
    final response = await _client.dio.post(
      '/api/user/login',
      data: {
        'account': account,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Token is empty',
      );
    }
    return token;
  }

  Future<UserProfileModel> getProfile() async {
    final response = await _client.dio.get('/api/user/profile');
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfileModel> updateProfile({
    String? userName,
    String? fullName,
    String? avatarUrl,
  }) async {
    final response = await _client.dio.put(
      '/api/user/profile',
      data: {
        'userName': userName,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
      },
    );
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
