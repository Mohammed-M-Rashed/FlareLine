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
    int? _toIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed;
      }
      if (value is double) return value.toInt();
      return null;
    }

    // Safely extract country name
    String? getCountryName(dynamic country) {
      if (country == null) return null;
      if (country is Map<String, dynamic>) {
        return country['name'] as String?;
      }
      if (country is String) return country;
      return null;
    }

    // Safely extract city name
    String? getCityName(dynamic city) {
      if (city == null) return null;
      if (city is Map<String, dynamic>) {
        return city['name'] as String?;
      }
      if (city is String) return city;
      return null;
    }

    return Company(
      id: _toIntNullable(json['id']),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      apiUrl: json['api_url'],
      countryId: _toIntNullable(json['country_id']),
      cityId: _toIntNullable(json['city_id']),
      countryName: getCountryName(json['country']),
      cityName: getCityName(json['city']),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
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
    int _toInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? defaultValue;
      }
      if (value is double) return value.toInt();
      return defaultValue;
    }

    List<Company> companies = [];
    try {
      if (json['data'] != null) {
        if (json['data'] is List) {
          companies = (json['data'] as List)
              .map((item) {
                try {
                  if (item is Map<String, dynamic>) {
                    return Company.fromJson(item);
                  }
                  return null;
                } catch (e) {
                  print('❌ Error parsing company: $e');
                  print('❌ Company data: $item');
                  return null;
                }
              })
              .whereType<Company>()
              .toList();
        } else {
          print('⚠️ CompanyListResponse: data is not a List, type: ${json['data'].runtimeType}');
        }
      }
    } catch (e) {
      print('❌ Error parsing companies list: $e');
      print('❌ JSON data: $json');
    }

    return CompanyListResponse(
      success: json['success'] ?? false,
      data: companies,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: _toInt(json['status_code'], defaultValue: 200),
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
    int _toInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? defaultValue;
      }
      if (value is double) return value.toInt();
      return defaultValue;
    }

    Company? company;
    try {
      if (json['data'] != null) {
        if (json['data'] is Map<String, dynamic>) {
          company = Company.fromJson(json['data'] as Map<String, dynamic>);
        } else {
          print('⚠️ CompanyResponse: data is not a Map, type: ${json['data'].runtimeType}');
        }
      }
    } catch (e) {
      print('❌ Error parsing company: $e');
      print('❌ JSON data: $json');
    }

    return CompanyResponse(
      success: json['success'] ?? false,
      data: company,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: _toInt(json['status_code'], defaultValue: 200),
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
