class UserModel {
  final String id;
  final String name;
  final String studentId;
  final String faculty;
  final String role; // 'Admin' or 'User'
  final String? profilePic;
  final String email;
  final String? bio;

  UserModel({
    required this.id,
    required this.name,
    required this.studentId,
    required this.faculty,
    required this.role,
    this.profilePic,
    required this.email,
    this.bio,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      studentId: json['studentId'] ?? '',
      faculty: json['faculty'] ?? '',
      role: json['role'] ?? 'User',
      profilePic: json['profilePic'],
      email: json['email'] ?? '',
      bio: json['bio'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'faculty': faculty,
      'role': role,
      'profilePic': profilePic,
      'email': email,
      'bio': bio,
    };
  }
}
