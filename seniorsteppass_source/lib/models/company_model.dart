import 'review_model.dart';

class CompanyModel {
  final String id;
  final String name;
  final String department;
  final String logoUrl;
  final String description;
  final double overallRating;
  final int reviewCount;
  final List<ReviewModel> reviews;
  final String location;
  final String website;

  CompanyModel({
    required this.id,
    required this.name,
    required this.department,
    required this.logoUrl,
    required this.description,
    required this.overallRating,
    required this.reviewCount,
    required this.reviews,
    required this.location,
    required this.website,
  });

  // Convert from JSON
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    var reviewsList = (json['reviews'] as List<dynamic>?)
        ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return CompanyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      description: json['description'] ?? '',
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      reviews: reviewsList,
      location: json['location'] ?? '',
      website: json['website'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'logoUrl': logoUrl,
      'description': description,
      'overallRating': overallRating,
      'reviewCount': reviewCount,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'location': location,
      'website': website,
    };
  }
}
