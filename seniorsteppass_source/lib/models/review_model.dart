import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String reviewer_id;
  final String position;
  final String comment;
  final double rating;
  final List<String> techStack;
  final DateTime timestamp;
  final String company;

  ReviewModel({
    required this.id,
    required this.reviewer_id,
    required this.position,
    required this.comment,
    required this.rating,
    required this.techStack,
    required this.timestamp,
    required this.company,
  });

  // Convert from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json, String docId) {
    return ReviewModel(
      id: docId,
      reviewer_id: json['reviewer_id'] ?? '',
      position: json['position'] ?? '',
      comment: json['comment'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      techStack: List<String>.from(json['techStack'] ?? []),
      timestamp: json['timestamp'] != null 
                ? (json['timestamp'] as Timestamp).toDate() 
                : DateTime.now(),    
      company: json['company'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'reviewer_id': reviewer_id,
      'position': position,
      'comment': comment,
      'rating': rating,
      'techStack': techStack,
      'timestamp': Timestamp.fromDate(timestamp),
      'company': company,
    };
  }
}
