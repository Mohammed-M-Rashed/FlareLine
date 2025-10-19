// City Management Models
import 'package:flutter/material.dart';
import 'country_model.dart';

// City model for city management operations
class City {
  final int? id;
  final String name;
  final int countryId;
  final String? createdAt;
  final String? updatedAt;
  
  // Related data
  final Country? country;

  City({
    this.id,
    required this.name,
    required this.countryId,
    this.createdAt,
    this.updatedAt,
    this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'] ?? '',
      countryId: json['country_id'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      country: json['country'] != null 
          ? Country.fromJson(json['country']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'country_id': countryId,
    };
    
    if (id != null) data['id'] = id;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    
    return data;
  }

  City copyWith({
    int? id,
    String? name,
    int? countryId,
    String? createdAt,
    String? updatedAt,
    Country? country,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      countryId: countryId ?? this.countryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      country: country ?? this.country,
    );
  }

  @override
  String toString() {
    return 'City(id: $id, name: $name, countryId: $countryId, country: ${country?.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City &&
        other.id == id &&
        other.name == name &&
        other.countryId == countryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ countryId.hashCode;
  }
}

// City Create Request model
class CityCreateRequest {
  final String name;
  final int countryId;

  CityCreateRequest({
    required this.name,
    required this.countryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country_id': countryId,
    };
  }
}

// City Update Request model
class CityUpdateRequest {
  final String name;
  final int countryId;

  CityUpdateRequest({
    required this.name,
    required this.countryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country_id': countryId,
    };
  }
}

// API Response models
class CityResponse {
  final bool success;
  final City? data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  CityResponse({
    required this.success,
    this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? City.fromJson(json['data']) : null,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class CitiesResponse {
  final bool success;
  final List<City> data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  CitiesResponse({
    required this.success,
    required this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    List<City> cities = [];
    if (json['data'] != null && json['data'] is List) {
      cities = (json['data'] as List)
          .map((cityJson) => City.fromJson(cityJson))
          .toList();
    }

    return CitiesResponse(
      success: json['success'] ?? false,
      data: cities,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}
