class UserProfile {
  final String id;
  final String authId;
  final String email;
  final String? displayName;
  final String? role;
  final DateTime? lastLoginAt;
  final String? photoUrl;
  final String? preferredLanguage;
  final String? theme;
  final String? level;
  final int? semester;
  final String? career;

  const UserProfile({
    required this.id,
    required this.authId,
    required this.email,
    this.displayName,
    this.role,
    this.lastLoginAt,
    this.photoUrl,
    this.preferredLanguage,
    this.theme,
    this.level,
    this.semester,
    this.career,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? lastLogin;
    final rawLastLogin = json['lastLoginAt'];
    if (rawLastLogin is String && rawLastLogin.isNotEmpty) {
      lastLogin = DateTime.tryParse(rawLastLogin);
    }

    final id = json['id'];
    final authId = json['authId'] ?? json['auth_id'];
    final email = json['email'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('UserProfile.id inválido');
    }
    if (authId is! String || authId.isEmpty) {
      throw const FormatException('UserProfile.authId inválido');
    }
    if (email is! String || email.isEmpty) {
      throw const FormatException('UserProfile.email inválido');
    }

    int? semester;
    final rawSemester = json['semester'];
    if (rawSemester is int) {
      semester = rawSemester;
    } else if (rawSemester is num) {
      semester = rawSemester.toInt();
    }

    return UserProfile(
      id: id,
      authId: authId,
      email: email,
      displayName:
          json['displayName'] as String? ?? json['display_name'] as String?,
      role: json['role'] as String?,
      lastLoginAt: lastLogin,
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
      preferredLanguage:
          json['preferredLanguage'] as String? ??
          json['preferred_language'] as String?,
      theme: json['theme'] as String?,
      level: json['level'] as String?,
      semester: semester,
      career: json['career'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authId': authId,
      'email': email,
      'displayName': displayName,
      'role': role,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'photoUrl': photoUrl,
      'preferredLanguage': preferredLanguage,
      'theme': theme,
      'level': level,
      'semester': semester,
      'career': career,
    }..removeWhere((key, value) => value == null);
  }
}

class ProfileUpdateRequest {
  final String? displayName;
  final String? photoUrl;
  final String? preferredLanguage;
  final String? theme;
  final String? level;
  final int? semester;
  final String? career;

  const ProfileUpdateRequest({
    this.displayName,
    this.photoUrl,
    this.preferredLanguage,
    this.theme,
    this.level,
    this.semester,
    this.career,
  });

  Map<String, dynamic> toJson() {
    return {
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      if (theme != null) 'theme': theme,
      if (level != null) 'level': level,
      if (semester != null) 'semester': semester,
      if (career != null) 'career': career,
    };
  }
}
