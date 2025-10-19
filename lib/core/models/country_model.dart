// Country Management Models
import 'package:flutter/material.dart';

// Country model for country management operations
class Country {
  final int? id;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  Country({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
    };
    
    if (id != null) data['id'] = id;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    
    return data;
  }

  Country copyWith({
    int? id,
    String? name,
    String? createdAt,
    String? updatedAt,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Country(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}

// Country Create Request model
class CountryCreateRequest {
  final String name;

  CountryCreateRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// Country Update Request model
class CountryUpdateRequest {
  final String name;

  CountryUpdateRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// API Response models
class CountryResponse {
  final bool success;
  final Country? data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  CountryResponse({
    required this.success,
    this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? Country.fromJson(json['data']) : null,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class CountriesResponse {
  final bool success;
  final List<Country> data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  CountriesResponse({
    required this.success,
    required this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory CountriesResponse.fromJson(Map<String, dynamic> json) {
    List<Country> countries = [];
    if (json['data'] != null && json['data'] is List) {
      countries = (json['data'] as List)
          .map((countryJson) => Country.fromJson(countryJson))
          .toList();
    }

    return CountriesResponse(
      success: json['success'] ?? false,
      data: countries,
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}
