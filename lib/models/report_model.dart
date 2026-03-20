import 'package:roam_and_report/enums/report_status.dart';

class ReportModel {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime date;
  final String description;
  final String? longDescription;
  final List<String> photos;
  final int likes;
  final int dislikes;
  final Map<String, String> votes; // userid -> 'likes'/'dislikes'
  final String locationText;
  ReportStatus status;
  final String severity;

  ReportModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.description,
    this.longDescription,
    required this.photos,
    required this.likes,
    required this.dislikes,
    required this.votes,
    required this.locationText,
    required this.status,
    required this.severity,
  });

  ReportModel copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    DateTime? date,
    String? description,
    String? longDescription,
    List<String>? photos,
    int? likes,
    int? dislikes,
    Map<String, String>? votes,
    String? locationText,
    ReportStatus? status,
    String? severity,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      photos: photos ?? this.photos,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      votes: votes ?? this.votes,
      locationText: locationText ?? this.locationText,
      status: status ?? this.status,
      severity: severity ?? this.severity,
    );
  }
}
