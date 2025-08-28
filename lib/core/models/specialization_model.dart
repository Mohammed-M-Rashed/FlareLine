class Specialization {
  final int? id;
  final String name;
  final String? description;
  final String createdAt;
  final String updatedAt;

  Specialization({
    this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    
    if (id != null) data['id'] = id;
    if (description != null) data['description'] = description;
    
    return data;
  }

  Specialization copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return Specialization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Specialization(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Specialization &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ (description?.hashCode ?? 0);
  }
}

class SpecializationListResponse {
  final bool success;
  final List<Specialization> data;
  final String mAr;
  final String mEn;
  final int statusCode;

  SpecializationListResponse({
    required this.success,
    required this.data,
    required this.mAr,
    required this.mEn,
    required this.statusCode,
  });

  factory SpecializationListResponse.fromJson(Map<String, dynamic> json) {
    return SpecializationListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
              ?.map((item) => Specialization.fromJson(item))
              .toList() ??
          [],
      mAr: json['m_ar'] ?? '',
      mEn: json['m_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class SpecializationResponse {
  final bool success;
  final Specialization? data;
  final String mAr;
  final String mEn;
  final int statusCode;

  SpecializationResponse({
    required this.success,
    this.data,
    required this.mAr,
    required this.mEn,
    required this.statusCode,
  });

  factory SpecializationResponse.fromJson(Map<String, dynamic> json) {
    return SpecializationResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? Specialization.fromJson(json['data']) : null,
      mAr: json['m_ar'] ?? '',
      mEn: json['m_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class SpecializationCreateRequest {
  final String name;
  final String? description;

  SpecializationCreateRequest({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
    };
    
    if (description != null) data['description'] = description;
    
    return data;
  }
}

class SpecializationUpdateRequest {
  final int id;
  final String name;
  final String? description;

  SpecializationUpdateRequest({
    required this.id,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
    };
    
    if (description != null) data['description'] = description;
    
    return data;
  }
}
