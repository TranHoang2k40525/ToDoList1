class UserProfileEntity {
  const UserProfileEntity({
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
}
