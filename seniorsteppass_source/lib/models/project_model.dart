import 'package:cloud_firestore/cloud_firestore.dart';

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
      name: '',
      role: json['role'] ?? '',
      profilePic: null,
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
  final String owner_id;
  final String image_url;
  final List<String> tags;
  final List<String> categories;
  final List<TeamMember> members;
  final DateTime timestamp;
  final String status; // 'Active', 'Completed', 'Archived'
  final int views;
  final int likes;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.owner_id,
    required this.image_url,
    required this.tags,
    required this.categories,
    required this.members,
    required this.timestamp,
    required this.status,
    required this.views,
    required this.likes,
  });

  // Convert from JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json, String docId) {
    var membersList = (json['members'] as List<dynamic>?)
        ?.map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return ProjectModel(
      id: docId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      owner_id: json['owner_id'] ?? '',
      image_url: json['image_url'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      members: membersList,
      timestamp: json['timestamp'] != null 
        ? (json['timestamp'] as Timestamp).toDate() 
        : DateTime.now(),
      status: json['status'] ?? 'Active',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'owner_id': owner_id,
      'image_url': image_url,
      'tags': tags,
      'categories': categories,
      'members': members.map((e) => e.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'views': views,
      'likes': likes,
    };
  }
}
