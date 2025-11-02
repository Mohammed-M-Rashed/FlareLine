class Company {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String? image; // Image file path from server
  final String? apiUrl; // API URL for external integration
  final int? countryId;
  final int? cityId;
  final String? countryName;
  final String? cityName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Company({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.image,
    this.apiUrl,
    this.countryId,
    this.cityId,
    this.countryName,
    this.cityName,
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    return Company(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      apiUrl: json['api_url'],
      countryId: _toInt(json['country_id']),
      cityId: _toInt(json['city_id']),
      countryName: json['country']?['name'],
      cityName: json['city']?['name'],
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
      'country_id': countryId,
      'city_id': cityId,
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
    int? countryId,
    int? cityId,
    String? countryName,
    String? cityName,
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
      countryId: countryId ?? this.countryId,
      cityId: cityId ?? this.cityId,
      countryName: countryName ?? this.countryName,
      cityName: cityName ?? this.cityName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Company(id: $id, name: $name, address: $address, phone: $phone, image: ${image != null ? "has_image" : "no_image"}, apiUrl: $apiUrl)';
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
        other.apiUrl == apiUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ address.hashCode ^ phone.hashCode ^ (image?.hashCode ?? 0) ^ (apiUrl?.hashCode ?? 0);
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
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    return CompanyListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Company.fromJson(item))
              .toList() ??
          [],
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: _toInt(json['status_code']),
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
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    return CompanyResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? Company.fromJson(json['data']) : null,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: _toInt(json['status_code']),
    );
  }
}

class CompanyCreateRequest {
  final String name;
  final String address;
  final String phone;
  final String? image; // Base64 encoded image
  final String? apiUrl; // API URL for external integration
  final int? countryId;
  final int? cityId;

  CompanyCreateRequest({
    required this.name,
    required this.address,
    required this.phone,
    this.image,
    this.apiUrl,
    this.countryId,
    this.cityId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'address': address,
      'phone': phone,
    };
    if (image != null) data['image'] = image;
    if (apiUrl != null) data['api_url'] = apiUrl;
    if (countryId != null) data['country_id'] = countryId;
    if (cityId != null) data['city_id'] = cityId;
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
  final int? countryId;
  final int? cityId;

  CompanyUpdateRequest({
    required this.id,
    this.name,
    this.address,
    this.phone,
    this.image,
    this.apiUrl,
    this.countryId,
    this.cityId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (image != null) data['image'] = image;
    if (apiUrl != null) data['api_url'] = apiUrl;
    if (countryId != null) data['country_id'] = countryId;
    if (cityId != null) data['city_id'] = cityId;
    return data;
  }
}
