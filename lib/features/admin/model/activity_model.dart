/// Activity Model for Admin Activity Management
/// Based on API documentation from ACTIVITY_API_FRONTEND.md
class ActivityModel {
  final String activityId;
  final String activityName;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String organizer;
  final String? status; // "Akan Datang", "Ongoing", "Selesai" from backend
  final String? bannerImg;
  final List<String> previewImages;
  final String? category;

  ActivityModel({
    required this.activityId,
    required this.activityName,
    this.description,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.organizer,
    this.status,
    this.bannerImg,
    List<String>? previewImages,
    this.category,
  }) : previewImages = previewImages ?? [];

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      activityId: json['activity_id'] as String,
      activityName: json['activity_name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : null,
      location: json['location'] as String,
      organizer: json['organizer'] as String,
      status: json['status'] as String?,
      bannerImg: json['banner_img'] as String?,
      previewImages: json['preview_images'] != null
          ? List<String>.from(json['preview_images'] as List)
          : [],
      category: json['category'] as String?,
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

  ActivityModel copyWith({
    String? activityId,
    String? activityName,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? organizer,
    String? status,
    String? bannerImg,
    List<String>? previewImages,
    String? category,
  }) {
    return ActivityModel(
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      status: status ?? this.status,
      bannerImg: bannerImg ?? this.bannerImg,
      previewImages: previewImages ?? this.previewImages,
      category: category ?? this.category,
    );
  }

  // Helper getters
  bool get isUpcoming => status == 'Akan Datang';
  bool get isOngoing => status == 'Ongoing';
  bool get isCompleted => status == 'Selesai';

  String get displayStatus {
    // Backend sudah mengirim dalam format Title Case dengan spasi
    return status ?? 'Tidak Diketahui';
  }

  // Convert display status to API format (lowercase with underscore)
  String? get apiStatus {
    switch (status) {
      case 'Akan Datang':
        return 'akan_datang';
      case 'Ongoing':
        return 'ongoing';
      case 'Selesai':
        return 'selesai';
      default:
        return null;
    }
  }

  bool get hasEnded {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get isActive {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
}

/// Response model for activity list
class ActivityListResponse {
  final int totalCount;
  final List<ActivityModel> data;

  ActivityListResponse({
    required this.totalCount,
    required this.data,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) {
    return ActivityListResponse(
      totalCount: json['total_count'] as int,
      data: (json['data'] as List)
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/// Request model for creating/updating activity
class ActivityRequest {
  final String activityName;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String organizer;
  final String? status;
  final String? bannerImg;
  final List<String>? previewImages;
  final String? category;

  ActivityRequest({
    required this.activityName,
    this.description,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.organizer,
    this.status,
    this.bannerImg,
    this.previewImages,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'activity_name': activityName,
      if (description != null) 'description': description,
      'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      'location': location,
      'organizer': organizer,
      if (status != null) 'status': status,
      if (bannerImg != null) 'banner_img': bannerImg,
      if (previewImages != null) 'preview_images': previewImages,
      if (category != null) 'category': category,
    };
  }
}

/// Upload images response
class UploadImagesResponse {
  final String activityId;
  final List<String> uploadedImages;
  final int totalImages;

  UploadImagesResponse({
    required this.activityId,
    required this.uploadedImages,
    required this.totalImages,
  });

  factory UploadImagesResponse.fromJson(Map<String, dynamic> json) {
    return UploadImagesResponse(
      activityId: json['activity_id'] as String,
      uploadedImages: List<String>.from(json['uploaded_images'] as List),
      totalImages: json['total_images'] as int,
    );
  }
}
