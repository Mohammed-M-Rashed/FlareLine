class EducationLevel {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EducationLevel({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory EducationLevel.fromJson(Map<String, dynamic> json) {
    return EducationLevel(
      id: json['id'],
      name: json['name'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  EducationLevel copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EducationLevel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EducationLevel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EducationLevel &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}

// API Response models for education level management
class EducationLevelListResponse {
  final bool success;
  final List<EducationLevel> data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  EducationLevelListResponse({
    required this.success,
    required this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory EducationLevelListResponse.fromJson(Map<String, dynamic> json) {
    return EducationLevelListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => EducationLevel.fromJson(item))
              .toList() ??
          [],
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class EducationLevelResponse {
  final bool success;
  final EducationLevel? data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  EducationLevelResponse({
    required this.success,
    this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory EducationLevelResponse.fromJson(Map<String, dynamic> json) {
    return EducationLevelResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? EducationLevel.fromJson(json['data']) : null,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class EducationLevelCreateRequest {
  final String name;

  EducationLevelCreateRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class EducationLevelUpdateRequest {
  final int id;
  final String? name;

  EducationLevelUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}
