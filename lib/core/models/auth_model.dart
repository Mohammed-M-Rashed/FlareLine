// Authentication and Login related models - SEPARATE from User Management
class AuthUserModel {
  final int id;
  final String name;
  final String email;
  final int? companyId;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final CompanyModel? company;
  final List<UserRole> roles;

  AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.companyId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.company,
    this.roles = const [],
  });

  // Helper function to safely convert dynamic to int?
  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    if (value is double) return value.toInt();
    return null;
  }

  // Helper function to safely convert dynamic to int (non-nullable)
  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }
    if (value is double) return value.toInt();
    return defaultValue;
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    print('🔍 AUTH MODEL: Parsing AuthUserModel from JSON: $json');
    try {
      final user = AuthUserModel(
        id: _toInt(json['id']),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        companyId: _toIntNullable(json['company_id']),
        status: json['status'] ?? 'active',
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        company: json['company'] != null ? CompanyModel.fromJson(json['company']) : null,
        roles: (json['roles'] as List?)
                ?.map((role) => UserRole.fromJson(role))
                .toList() ??
            [],
      );
      print('✅ AUTH MODEL: Successfully parsed AuthUserModel: ${user.name} (${user.email})');
      print('✅ AUTH MODEL: User roles: ${user.roles.map((r) => r.name).join(', ')}');
      return user;
    } catch (e) {
      print('❌ AUTH MODEL: Error parsing AuthUserModel: $e');
      print('❌ AUTH MODEL: Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'company_id': companyId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'company': company?.toJson(),
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }
}

class CompanyModel {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String status;

  CompanyModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.status,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    print('🔍 AUTH MODEL: Parsing CompanyModel from JSON: $json');
    try {
      final company = CompanyModel(
        id: AuthUserModel._toInt(json['id']),
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        address: json['address'] ?? '',
        status: json['status'] ?? 'active',
      );
      print('✅ AUTH MODEL: Successfully parsed CompanyModel: ${company.name}');
      return company;
    } catch (e) {
      print('❌ AUTH MODEL: Error parsing CompanyModel: $e');
      print('❌ AUTH MODEL: Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'status': status,
    };
  }
}

class UserRole {
  final int id;
  final String name;
  final String displayName;
  final String description;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> pivot;

  UserRole({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    print('🔍 AUTH MODEL: Parsing UserRole from JSON: $json');
    try {
      final role = UserRole(
        id: AuthUserModel._toInt(json['id']),
        name: json['name'] ?? '',
        displayName: json['display_name'] ?? '',
        description: json['description'] ?? '',
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        pivot: json['pivot'] ?? {},
      );
      print('✅ AUTH MODEL: Successfully parsed UserRole: ${role.name}');
      return role;
    } catch (e) {
      print('❌ AUTH MODEL: Error parsing UserRole: $e');
      print('❌ AUTH MODEL: Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'pivot': pivot,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final AuthUserModel user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 AUTH MODEL: Parsing LoginResponse from JSON: $json');
    try {
      final response = LoginResponse(
        accessToken: json['access_token'] ?? '',
        tokenType: json['token_type'] ?? 'bearer',
        expiresIn: AuthUserModel._toInt(json['expires_in'], defaultValue: 3600),
        user: AuthUserModel.fromJson(json['user']),
      );
      print('✅ AUTH MODEL: Successfully parsed LoginResponse: tokenType=${response.tokenType}, expiresIn=${response.expiresIn}');
      print('✅ AUTH MODEL: User: ${response.user.name} (${response.user.email})');
      print('✅ AUTH MODEL: User roles: ${response.user.roles.map((r) => r.name).join(', ')}');
      return response;
    } catch (e) {
      print('❌ AUTH MODEL: Error parsing LoginResponse: $e');
      print('❌ AUTH MODEL: Problematic JSON: $json');
      rethrow;
    }
  }
}


