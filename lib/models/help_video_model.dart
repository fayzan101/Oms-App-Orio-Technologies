class HelpVideoModel {
  final String id;
  final String title;
  final String type;
  final String postLink;
  final String duration;
  final String postDate;
  final String status;

  HelpVideoModel({
    required this.id,
    required this.title,
    required this.type,
    required this.postLink,
    required this.duration,
    required this.postDate,
    required this.status,
  });

  factory HelpVideoModel.fromJson(Map<String, dynamic> json) {
    return HelpVideoModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      postLink: json['post_link'] ?? '',
      duration: json['duration'] ?? '',
      postDate: json['post_date'] ?? '',
      status: json['status'] ?? '',
    );
  }
} 