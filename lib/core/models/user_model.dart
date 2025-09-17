// User Management Models - SEPARATE from Authentication
import 'package:flutter/material.dart';
import 'company_model.dart';

// Role model for user roles
class Role {
  final int? id;
  final String name;
  final String displayName;
  final String? description;
  final List<String>? permissions;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? pivot;

  Role({
    this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.permissions,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    // Handle permissions - can be array or null
    List<String>? permissions;
    if (json['permissions'] != null) {
      if (json['permissions'] is List) {
        permissions = (json['permissions'] as List)
            .map((item) => item.toString())
            .toList();
      }
    }

    return Role(
      id: json['id'],
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? json['name'] ?? '',
      description: json['description'],
      permissions: permissions,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      pivot: json['pivot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'permissions': permissions,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'pivot': pivot,
    };
  }
}

// User model for user management operations
class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? role; // Keep for backward compatibility
  final List<Role> roles; // New roles array
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final int? companyId;
  final String? status;
  final Company? company;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.role,
    this.roles = const [],
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.companyId,
    this.status,
    this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle roles array
    List<Role> roles = [];
    if (json['roles'] != null && json['roles'] is List) {
      roles = (json['roles'] as List)
          .map((roleJson) => Role.fromJson(roleJson))
          .toList();
    }
    
    // Handle legacy single role field for backward compatibility
    String? legacyRole;
    if (json['role'] != null) {
      legacyRole = json['role'];
    }

    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: legacyRole,
      roles: roles,
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      companyId: json['company_id'],
      status: json['status'],
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    
    if (id != null) data['id'] = id;
    if (password != null) data['password'] = password;
    if (role != null) data['role'] = role;
    if (roles.isNotEmpty) data['roles'] = roles.map((role) => role.toJson()).toList();
    if (emailVerifiedAt != null) data['email_verified_at'] = emailVerifiedAt;
    if (companyId != null) data['company_id'] = companyId;
    if (status != null) data['status'] = status;
    
    return data;
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? role,
    List<Role>? roles,
    String? emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
    int? companyId,
    String? status,
    Company? company,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      companyId: companyId ?? this.companyId,
      status: status ?? this.status,
      company: company ?? this.company,
    );
  }

  // Helper method to get the display name of the first role
  String getFirstRoleDisplayName() {
    if (roles.isEmpty) {
      return 'N/A';
    }
    return roles.first.displayName;
  }

  // Helper method to get the first role name (for backward compatibility)
  String getFirstRoleName() {
    if (roles.isEmpty) {
      return role != null ? role! : 'company_account';
    }
    return roles.first.name;
  }

  // Helper method to check if user is active
  bool get isActive {
    return (status ?? 'active').toLowerCase() == 'active';
  }

  // Helper method to check if user is inactive
  bool get isInactive {
    return (status ?? 'active').toLowerCase() == 'inactive';
  }

  // Helper method to check if user is pending
  bool get isPending {
    return (status ?? 'active').toLowerCase() == 'pending';
  }

  // Helper method to check if user is suspended
  bool get isSuspended {
    return (status ?? 'active').toLowerCase() == 'suspended';
  }

  // Helper method to get status display text
  String get statusDisplayText {
    final currentStatus = status ?? 'active';
    switch (currentStatus.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'inactive':
        return 'غير نشط';
      case 'pending':
        return 'في الانتظار';
      case 'suspended':
        return 'معلق';
      default:
        return 'نشط';
    }
  }

  // Helper method to get status color
  Color get statusColor {
    final currentStatus = status ?? 'active';
    switch (currentStatus.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  // Helper method to check if user is a system administrator
  bool get isSystemAdministrator {
    if (roles.isEmpty) {
      return role?.toLowerCase() == 'system_administrator';
    }
    return roles.any((role) => role.name.toLowerCase() == 'system_administrator');
  }

  // Helper method to check if user is a training general manager
  bool get isTrainingGeneralManager {
    if (roles.isEmpty) {
      return role?.toLowerCase() == 'training_general_manager';
    }
    return roles.any((role) => role.name.toLowerCase() == 'training_general_manager');
  }

  // Helper method to check if user is a board chairman
  bool get isBoardChairman {
    if (roles.isEmpty) {
      return role?.toLowerCase() == 'board_chairman';
    }
    return roles.any((role) => role.name.toLowerCase() == 'board_chairman');
  }

  // Helper method to check if user has a unique role (can only be assigned to one user)
  bool get hasUniqueRole {
    return isSystemAdministrator || isTrainingGeneralManager || isBoardChairman;
  }

  // Helper method to check if user status can be changed
  bool get canChangeStatus {
    return !hasUniqueRole;
  }

  // Helper method to get status change restriction message
  String get statusChangeRestrictionMessage {
    if (isSystemAdministrator) {
      return 'لا يمكن تغيير حالة مدير النظام';
    }
    if (isTrainingGeneralManager) {
      return 'لا يمكن تغيير حالة المدير العام للتدريب';
    }
    if (isBoardChairman) {
      return 'لا يمكن تغيير حالة رئيس مجلس الإدارة';
    }
    return '';
  }
}





// API Response models for user management
class UserListResponse {
  final bool success;
  final List<User> data;
  final String message;
  final int statusCode;

  UserListResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
              ?.map((user) => User.fromJson(user))
              .toList() ??
          [],
      message: json['message'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class UserResponse {
  final bool success;
  final User data;
  final String message;
  final int statusCode;

  UserResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'] ?? false,
      data: User.fromJson(json['data']),
      message: json['message'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class ApiErrorResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? errors;
  final int statusCode;

  ApiErrorResponse({
    required this.success,
    required this.message,
    this.errors,
    required this.statusCode,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errors: json['errors'],
      statusCode: json['status_code'] ?? 0,
    );
  }
}
