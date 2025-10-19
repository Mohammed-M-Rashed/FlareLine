import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/country_model.dart';
import 'auth_service.dart';
import '../config/api_config.dart';
import '../config/api_endpoints.dart';

class CountryService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Get all countries
  static Future<CountriesResponse> getAllCountries() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllCountries}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API pattern
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CountriesResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? errorData['message_en'] ?? 'Failed to fetch countries');
        } catch (e) {
          throw Exception('Failed to fetch countries: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new country
  static Future<CountryResponse> createCountry(CountryCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createCountry}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return CountryResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error
            final errors = errorData['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              final errorMessages = errors.values
                  .expand((e) => e as List<dynamic>)
                  .map((e) => e.toString())
                  .join(', ');
              throw Exception('Validation error: $errorMessages');
            }
          }
          throw Exception(errorData['message_ar'] ?? errorData['message_en'] ?? 'Failed to create country');
        } catch (e) {
          throw Exception('Failed to create country: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing country
  static Future<CountryResponse> updateCountry(int id, CountryUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final requestBody = request.toJson();
      requestBody['id'] = id; // Add ID to request body

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateCountry}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CountryResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          if (response.statusCode == 422) {
            // Validation error
            final errors = errorData['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              final errorMessages = errors.values
                  .expand((e) => e as List<dynamic>)
                  .map((e) => e.toString())
                  .join(', ');
              throw Exception('Validation error: $errorMessages');
            }
          }
          throw Exception(errorData['message_ar'] ?? errorData['message_en'] ?? 'Failed to update country');
        } catch (e) {
          throw Exception('Failed to update country: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a country
  static Future<bool> deleteCountry(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.deleteCountry}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['success'] ?? false;
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? errorData['message_en'] ?? 'Failed to delete country');
        } catch (e) {
          throw Exception('Failed to delete country: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check if user has country management permission
  static bool hasCountryManagementPermission() {
    return AuthService.hasRole('admin');
  }
}

// Data Provider for Country Management
class CountryDataProvider extends GetxController {
  final RxList<Country> _countries = <Country>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final searchController = TextEditingController();

  List<Country> get countries => _countries.toList();
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;

  List<Country> get filteredCountries {
    var filtered = _countries.toList();
    
    // Filter by search query (case-insensitive)
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((country) =>
        country.name.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  @override
  void onInit() {
    super.onInit();
    refreshData();
    
    // Add listener to search controller
    searchController.addListener(() {
      setSearchQuery(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> refreshData() async {
    try {
      _isLoading.value = true;
      final response = await CountryService.getAllCountries();
      
      if (response.success) {
        _countries.assignAll(response.data);
      } else {
        throw Exception(response.messageEn.isNotEmpty ? response.messageEn : response.messageAr);
      }
    } catch (e) {
      print('Error refreshing countries data: $e');
      // You might want to show a toast or snackbar here
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createCountry(CountryCreateRequest request) async {
    try {
      final response = await CountryService.createCountry(request);
      
      if (response.success && response.data != null) {
        _countries.add(response.data!);
        update();
      } else {
        throw Exception(response.messageEn.isNotEmpty ? response.messageEn : response.messageAr);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCountry(int id, CountryUpdateRequest request) async {
    try {
      final response = await CountryService.updateCountry(id, request);
      
      if (response.success && response.data != null) {
        final index = _countries.indexWhere((country) => country.id == id);
        if (index != -1) {
          _countries[index] = response.data!;
          update();
        }
      } else {
        throw Exception(response.messageEn.isNotEmpty ? response.messageEn : response.messageAr);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCountry(int id) async {
    try {
      final success = await CountryService.deleteCountry(id);
      
      if (success) {
        _countries.removeWhere((country) => country.id == id);
        update();
      } else {
        throw Exception('Failed to delete country');
      }
    } catch (e) {
      rethrow;
    }
  }
}
