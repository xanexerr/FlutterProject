class UserModel {
  final String id;
  final String full_name;
  final String student_id;
  final String faculty;
  final String role; // 'Admin' or 'User'
  final String? profilePic;
  final String email;
  final String? bio;
  final List<dynamic>? intern_list;

  UserModel({
    required this.id,
    required this.full_name,
    required this.student_id,
    required this.faculty,
    required this.role,
    this.profilePic,
    required this.email,
    this.bio,
    this.intern_list,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      id: docId,
      full_name: json['full_name'] ?? '',
      student_id: json['student_id'] ?? '',
      faculty: json['faculty'] ?? '',
      role: json['role'] ?? 'User',
      profilePic: json['profilePic'],
      email: json['email'] ?? '',
      bio: json['bio']?.toString(),
      intern_list: json['intern_list'] as List<dynamic>?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'full_name': full_name,
      'student_id': student_id,
      'faculty': faculty,
      'role': role,
      'profilePic': profilePic,
      'email': email,
      'bio': bio,
      'intern_list': intern_list,

    };
  }
}
