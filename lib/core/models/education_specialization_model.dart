class EducationSpecialization {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EducationSpecialization({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory EducationSpecialization.fromJson(Map<String, dynamic> json) {
    return EducationSpecialization(
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

  EducationSpecialization copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EducationSpecialization(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EducationSpecialization(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EducationSpecialization &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}

// API Response models for education specialization management
class EducationSpecializationListResponse {
  final bool success;
  final List<EducationSpecialization> data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  EducationSpecializationListResponse({
    required this.success,
    required this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory EducationSpecializationListResponse.fromJson(Map<String, dynamic> json) {
    return EducationSpecializationListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => EducationSpecialization.fromJson(item))
              .toList() ??
          [],
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class EducationSpecializationResponse {
  final bool success;
  final EducationSpecialization? data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  EducationSpecializationResponse({
    required this.success,
    this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory EducationSpecializationResponse.fromJson(Map<String, dynamic> json) {
    return EducationSpecializationResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? EducationSpecialization.fromJson(json['data']) : null,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class EducationSpecializationCreateRequest {
  final String name;

  EducationSpecializationCreateRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class EducationSpecializationUpdateRequest {
  final int id;
  final String? name;

  EducationSpecializationUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}
