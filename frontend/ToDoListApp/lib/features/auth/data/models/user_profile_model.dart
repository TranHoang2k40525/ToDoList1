import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String userName;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final DateTime createdAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      userName: userName,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
