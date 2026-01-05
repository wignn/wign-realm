class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? profilePic;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.profilePic,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'User',
      profilePic: json['profile_pic'],
      bio: json['bio'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'profile_pic': profilePic,
      'bio': bio,
    };
  }

  bool get isAdmin => role == 'Admin';
}

class AuthResponse {
  final User user;
  final String? accessToken;
  final String? refreshToken;

  AuthResponse({required this.user, this.accessToken, this.refreshToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AuthResponse(
      user: User.fromJson(data['user'] ?? data),
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
  }
}
