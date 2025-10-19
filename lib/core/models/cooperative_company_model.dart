class CooperativeCompany {
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

  CooperativeCompany({
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

  factory CooperativeCompany.fromJson(Map<String, dynamic> json) {
    return CooperativeCompany(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      apiUrl: json['api_url'],
      countryId: json['country_id'],
      cityId: json['city_id'],
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

  CooperativeCompany copyWith({
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
    return CooperativeCompany(
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
    return 'CooperativeCompany(id: $id, name: $name, address: $address, phone: $phone, image: ${image != null ? "has_image" : "no_image"}, apiUrl: $apiUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CooperativeCompany &&
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

// Request models for API calls
class CooperativeCompanyCreateRequest {
  final String name;
  final String address;
  final String phone;
  final String? image;
  final String? apiUrl;
  final int? countryId;
  final int? cityId;

  CooperativeCompanyCreateRequest({
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

class CooperativeCompanyUpdateRequest {
  final int id;
  final String? name;
  final String? address;
  final String? phone;
  final String? image;
  final String? apiUrl;
  final int? countryId;
  final int? cityId;

  CooperativeCompanyUpdateRequest({
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

// Response models
class CooperativeCompanyResponse {
  final bool success;
  final String? messageAr;
  final String? messageEn;
  final int? statusCode;
  final CooperativeCompany? data;

  CooperativeCompanyResponse({
    required this.success,
    this.messageAr,
    this.messageEn,
    this.statusCode,
    this.data,
  });

  factory CooperativeCompanyResponse.fromJson(Map<String, dynamic> json) {
    return CooperativeCompanyResponse(
      success: json['success'] ?? false,
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: json['status_code'],
      data: json['data'] != null ? CooperativeCompany.fromJson(json['data']) : null,
    );
  }
}

class CooperativeCompanyListResponse {
  final bool success;
  final String? messageAr;
  final String? messageEn;
  final int? statusCode;
  final List<CooperativeCompany> data;

  CooperativeCompanyListResponse({
    required this.success,
    this.messageAr,
    this.messageEn,
    this.statusCode,
    required this.data,
  });

  factory CooperativeCompanyListResponse.fromJson(Map<String, dynamic> json) {
    return CooperativeCompanyListResponse(
      success: json['success'] ?? false,
      messageAr: json['message_ar'],
      messageEn: json['message_en'],
      statusCode: json['status_code'],
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => CooperativeCompany.fromJson(item))
          .toList() ?? [],
    );
  }
}
