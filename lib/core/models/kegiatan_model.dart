class KegiatanModel {
  final String activityId;
  final String activityName;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String organizer;
  final String status; // 'akan_datang', 'ongoing', 'selesai'
  final String? bannerImg;
  final List<String> previewImages;
  final String category; // 'sosial', 'keagamaan', 'olahraga', 'pendidikan', 'lainnya'

  KegiatanModel({
    required this.activityId,
    required this.activityName,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.organizer,
    required this.status,
    this.bannerImg,
    required this.previewImages,
    required this.category,
  });

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    return KegiatanModel(
      activityId: json['activity_id'],
      activityName: json['activity_name'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      location: json['location'],
      organizer: json['organizer'],
      status: json['status'],
      bannerImg: json['banner_img'],
      previewImages: json['preview_images'] != null
          ? List<String>.from(json['preview_images'])
          : [],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'activity_name': activityName,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'status': status,
      'banner_img': bannerImg,
      'preview_images': previewImages,
      'category': category,
    };
  }
}
