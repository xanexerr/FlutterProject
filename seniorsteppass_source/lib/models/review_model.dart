class ReviewModel {
  final String id;
  final String reviewerName;
  final String position;
  final String content;
  final double rating;
  final List<String> techStack;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.position,
    required this.content,
    required this.rating,
    required this.techStack,
    required this.date,
  });

  // Convert from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      position: json['position'] ?? '',
      content: json['content'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      techStack: List<String>.from(json['techStack'] ?? []),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerName': reviewerName,
      'position': position,
      'content': content,
      'rating': rating,
      'techStack': techStack,
      'date': date.toIso8601String(),
    };
  }
}
