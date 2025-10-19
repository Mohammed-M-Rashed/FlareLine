import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/city_model.dart';
import '../models/country_model.dart';
import 'auth_service.dart';
import 'country_service.dart';
import '../config/api_config.dart';
import '../config/api_endpoints.dart';

class CityService {
  static String get _baseUrl => ApiConfig.baseUrl;
  
  // Get all cities
  static Future<CitiesResponse> getAllCities() async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.getAllCities}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty body as per API pattern
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CitiesResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message_ar'] ?? errorData['message_en'] ?? 'Failed to fetch cities');
        } catch (e) {
          throw Exception('Failed to fetch cities: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }


  // Create a new city
  static Future<CityResponse> createCity(CityCreateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.createCity}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return CityResponse.fromJson(jsonData);
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
          throw Exception(errorData['message_ar'] ?? errorData['message_en'] ?? 'Failed to create city');
        } catch (e) {
          throw Exception('Failed to create city: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing city
  static Future<CityResponse> updateCity(int id, CityUpdateRequest request) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final requestBody = request.toJson();
      requestBody['id'] = id; // Add ID to request body

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.updateCity}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CityResponse.fromJson(jsonData);
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
          throw Exception(errorData['message_ar'] ?? errorData['message_en'] ?? 'Failed to update city');
        } catch (e) {
          throw Exception('Failed to update city: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a city
  static Future<bool> deleteCity(int id) async {
    try {
      final token = AuthService.getAuthToken();
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.deleteCity}'),
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
          throw Exception(errorData['message_ar'] ?? errorData['message_en'] ?? 'Failed to delete city');
        } catch (e) {
          throw Exception('Failed to delete city: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check if user has city management permission
  static bool hasCityManagementPermission() {
    return AuthService.hasRole('admin');
  }
}

// Data Provider for City Management
class CityDataProvider extends GetxController {
  final RxList<City> _cities = <City>[].obs;
  final RxList<Country> _countries = <Country>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingCountries = false.obs;
  final Rxn<int> _selectedCountryId = Rxn<int>();
  final RxString _searchQuery = ''.obs;
  final searchController = TextEditingController();

  List<City> get cities => _cities.toList();
  List<Country> get countries => _countries.toList();
  bool get isLoading => _isLoading.value;
  bool get isLoadingCountries => _isLoadingCountries.value;
  int? get selectedCountryId => _selectedCountryId.value;
  String get searchQuery => _searchQuery.value;

  // Filtered cities based on selected country and search query
  List<City> get filteredCities {
    var filtered = _cities.toList();
    
    // Filter by selected country
    if (_selectedCountryId.value != null) {
      filtered = filtered.where((city) => city.countryId == _selectedCountryId.value).toList();
    }
    
    // Filter by search query (case-insensitive country name search)
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((city) =>
        city.country?.name.toLowerCase().contains(query) ?? false
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
    loadCountries();
    
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
      final response = await CityService.getAllCities();
      
      if (response.success) {
        _cities.assignAll(response.data);
      } else {
        throw Exception(response.messageEn.isNotEmpty ? response.messageEn : response.messageAr);
      }
    } catch (e) {
      print('Error refreshing cities data: $e');
      // You might want to show a toast or snackbar here
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadCountries() async {
    try {
      _isLoadingCountries.value = true;
      final response = await CountryService.getAllCountries();
      
      if (response.success) {
        _countries.assignAll(response.data);
      } else {
        throw Exception(response.messageEn.isNotEmpty ? response.messageEn : response.messageAr);
      }
    } catch (e) {
      print('Error loading countries: $e');
      // You might want to show a toast or snackbar here
      rethrow;
    } finally {
      _isLoadingCountries.value = false;
    }
  }

  void setSelectedCountry(int? countryId) {
    _selectedCountryId.value = countryId;
  }

  Future<void> createCity(CityCreateRequest request) async {
    try {
      final response = await CityService.createCity(request);
      
      if (response.success && response.data != null) {
        _cities.add(response.data!);
        update();
      } else {
        throw Exception(response.messageEn.isNotEmpty ? response.messageEn : response.messageAr);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCity(int id, CityUpdateRequest request) async {
    try {
      final response = await CityService.updateCity(id, request);
      
      if (response.success && response.data != null) {
        final index = _cities.indexWhere((city) => city.id == id);
        if (index != -1) {
          _cities[index] = response.data!;
          update();
        }
      } else {
        throw Exception(response.messageEn.isNotEmpty ? response.messageEn : response.messageAr);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCity(int id) async {
    try {
      final success = await CityService.deleteCity(id);
      
      if (success) {
        _cities.removeWhere((city) => city.id == id);
        update();
      } else {
        throw Exception('Failed to delete city');
      }
    } catch (e) {
      rethrow;
    }
  }
}
