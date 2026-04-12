import 'review_model.dart';

class CompanyModel {
  final String id;
  final String company_name;
  final String department;
  final String logo_url;
  final String description;
  final double overallRating;
  final int reviewCount;
  final List<ReviewModel> reviews;
  final String location;
  final String website;

  CompanyModel({
    required this.id,
    required this.company_name,
    required this.department,
    required this.logo_url,
    required this.description,
    required this.overallRating,
    required this.reviewCount,
    // required this.reviews,
    this.reviews = const [],
    required this.location,
    required this.website,
  });

  // Convert from JSON
  factory CompanyModel.fromJson(Map<String, dynamic> json, String docId) {
    return CompanyModel(
      id: docId,
      company_name: json['company_name'] ?? '',
      department: json['department'] ?? '',
      logo_url: json['logo_url'] ?? '',
      description: json['description'] ?? '',
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      // reviews: reviewsList,
      location: json['location'] ?? '',
      website: json['website'] ?? '',
      reviews: [],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'company_name': company_name,
      'department': department,
      'logo_url': logo_url,
      'description': description,
      'overallRating': overallRating,
      'reviewCount': reviewCount,
      // 'reviews': reviews.map((e) => e.toJson()).toList(),
      'location': location,
      'website': website,
    };
  }
}
