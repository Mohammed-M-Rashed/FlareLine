class Company {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String? image; // Image file path from server
  final String? apiUrl; // API URL for external integration
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Company({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.image,
    this.apiUrl,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      apiUrl: json['api_url'],
      status: json['status'],
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
      'address': address,
      'phone': phone,
      'image': image,
      'api_url': apiUrl,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Company copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? image,
    String? apiUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      apiUrl: apiUrl ?? this.apiUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Company(id: $id, name: $name, address: $address, phone: $phone, image: ${image != null ? "has_image" : "no_image"}, apiUrl: $apiUrl, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Company &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.phone == phone &&
        other.image == image &&
        other.apiUrl == apiUrl &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ address.hashCode ^ phone.hashCode ^ (image?.hashCode ?? 0) ^ (apiUrl?.hashCode ?? 0) ^ (status?.hashCode ?? 0);
  }
}

// API Response models for company management
class CompanyListResponse {
  final bool success;
  final List<Company> data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  CompanyListResponse({
    required this.success,
    required this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory CompanyListResponse.fromJson(Map<String, dynamic> json) {
    return CompanyListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Company.fromJson(item))
              .toList() ??
          [],
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class CompanyResponse {
  final bool success;
  final Company? data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  CompanyResponse({
    required this.success,
    this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? Company.fromJson(json['data']) : null,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class CompanyCreateRequest {
  final String name;
  final String address;
  final String phone;
  final String? image; // Base64 encoded image
  final String? apiUrl; // API URL for external integration

  CompanyCreateRequest({
    required this.name,
    required this.address,
    required this.phone,
    this.image,
    this.apiUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'address': address,
      'phone': phone,
    };
    if (image != null) data['image'] = image;
    if (apiUrl != null) data['api_url'] = apiUrl;
    return data;
  }
}

class CompanyUpdateRequest {
  final int id;
  final String? name;
  final String? address;
  final String? phone;
  final String? image; // Base64 encoded image
  final String? apiUrl; // API URL for external integration

  CompanyUpdateRequest({
    required this.id,
    this.name,
    this.address,
    this.phone,
    this.image,
    this.apiUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (image != null) data['image'] = image;
    if (apiUrl != null) data['api_url'] = apiUrl;
    return data;
  }
}
