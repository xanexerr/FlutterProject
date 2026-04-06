class TeamMember {
  final String id;
  final String name;
  final String role;
  final String? profilePic;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    this.profilePic,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      profilePic: json['profilePic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'profilePic': profilePic,
    };
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String author;
  final String imageUrl;
  final List<String> tags;
  final List<String> categories;
  final List<TeamMember> teamMembers;
  final DateTime createdDate;
  final String status; // 'Active', 'Completed', 'Archived'
  final int views;
  final int likes;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.imageUrl,
    required this.tags,
    required this.categories,
    required this.teamMembers,
    required this.createdDate,
    required this.status,
    required this.views,
    required this.likes,
  });

  // Convert from JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    var membersList = (json['teamMembers'] as List<dynamic>?)
        ?.map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      teamMembers: membersList,
      createdDate: json['createdDate'] != null 
        ? DateTime.parse(json['createdDate']) 
        : DateTime.now(),
      status: json['status'] ?? 'Active',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'imageUrl': imageUrl,
      'tags': tags,
      'categories': categories,
      'teamMembers': teamMembers.map((e) => e.toJson()).toList(),
      'createdDate': createdDate.toIso8601String(),
      'status': status,
      'views': views,
      'likes': likes,
    };
  }
}
