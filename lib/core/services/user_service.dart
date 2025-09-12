import 'package:flareline/core/models/user_model.dart';
import 'package:flareline/core/models/user_api_response.dart';
import 'package:flareline/core/models/auth_model.dart';
import 'package:flareline/core/models/company_model.dart';
import 'package:flareline/core/services/api_service.dart';
import 'package:flareline/core/config/api_endpoints.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class UserService {
  /// Shows a success toast notification for user operations in Arabic
  static void _showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text('نجح', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an error toast notification for user operations in Arabic
  static void _showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an info toast notification for user operations in Arabic
  static void _showInfoToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      title: Text('معلومات', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  // Get all users
  static Future<List<User>> getUsers(BuildContext context) async {
    print('👥 USER SERVICE: ===== GETTING ALL USERS =====');
    print('🌐 USER SERVICE: Calling API endpoint: ${ApiEndpoints.getAllUsers}');
    
    try {
      print('📡 USER SERVICE: Making POST request to get all users...');
      final response = await ApiService.post(ApiEndpoints.getAllUsers);
      print('📡 USER SERVICE: Response received - Status: ${response.statusCode}, Body: ${response.body}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ USER SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 USER SERVICE: Parsed response data: $responseData');
        print('🔍 USER SERVICE: Response data type: ${responseData.runtimeType}');
        print('🔍 USER SERVICE: Response data length: ${responseData is List ? responseData.length : 'N/A'}');
        print('🔍 USER SERVICE: Response data keys: ${responseData is Map ? responseData.keys.toList() : 'N/A'}');
        
        List<User> users = [];
        
        // Handle different response formats
        print('🔍 USER SERVICE: Analyzing response structure...');
        
        if (responseData is List) {
          print('📋 USER SERVICE: Response is a direct list, processing ${responseData.length} users...');
          try {
            users = responseData.map((userJson) {
              print('🔍 USER SERVICE: Processing user JSON: $userJson');
              return _convertToUser(UserApiData.fromJson(userJson));
            }).toList();
            print('✅ USER SERVICE: Successfully converted ${users.length} users from direct list');
          } catch (e) {
            print('❌ USER SERVICE: Error converting users from direct list: $e');
            print('🔍 USER SERVICE: Attempting alternative parsing...');
            
            // Try to parse as simple user objects
            try {
              users = responseData.map((userJson) {
                print('🔍 USER SERVICE: Attempting simple user parsing: $userJson');
                if (userJson is Map<String, dynamic>) {
                  // Create a minimal UserApiData from the raw JSON with roles array
                  List<Role> roles = [];
                  if (userJson['roles'] != null && userJson['roles'] is List) {
                    roles = (userJson['roles'] as List)
                        .map((roleJson) => Role.fromJson(roleJson))
                        .toList();
                  }
                  
                  final userData = UserApiData(
                    id: userJson['id'] ?? 0,
                    name: userJson['name'] ?? '',
                    email: userJson['email'] ?? '',
                    emailVerifiedAt: userJson['email_verified_at'],
                    companyId: userJson['company_id'],
                    status: userJson['status'] ?? 'active',
                    createdAt: userJson['created_at'],
                    updatedAt: userJson['updated_at'],
                    company: userJson['company'] != null ? Company.fromJson(userJson['company']) : null,
                    roles: roles,
                  );
                  return _convertToUser(userData);
                } else {
                  throw Exception('User JSON is not a Map: ${userJson.runtimeType}');
                }
              }).toList();
              print('✅ USER SERVICE: Successfully converted ${users.length} users using alternative parsing');
            } catch (altError) {
              print('💥 USER SERVICE: Alternative parsing also failed: $altError');
              _showErrorToast(context, 'خطأ في معالجة بيانات المستخدم: ${e.toString()}');
              return [];
            }
          }
                 } else if (responseData is Map<String, dynamic>) {
           print('📋 USER SERVICE: Response is a map, attempting to parse as UserApiResponse...');
           print('🔍 USER SERVICE: Map keys: ${responseData.keys.toList()}');
           print('🔍 USER SERVICE: Data field type: ${responseData['data']?.runtimeType}');
           print('🔍 USER SERVICE: Data field value: ${responseData['data']}');
           
           try {
             // Check if this is a simple response with just a data array
             if (responseData.containsKey('data') && responseData['data'] is List) {
               print('📋 USER SERVICE: Found direct data array, processing...');
               final dataList = responseData['data'] as List;
               print('🔍 USER SERVICE: Data array length: ${dataList.length}');
               
               try {
                 users = dataList.map((userJson) {
                   print('🔍 USER SERVICE: Processing user from data array: $userJson');
                   return _convertToUser(UserApiData.fromJson(userJson));
                 }).toList();
                 print('✅ USER SERVICE: Successfully converted ${users.length} users from data array');
               } catch (e) {
                 print('❌ USER SERVICE: Error converting users from data array: $e');
                 throw e;
               }
                          } else {
                               // Try to parse as full UserApiResponse
                print('📋 USER SERVICE: Attempting to parse as full UserApiResponse...');
                try {
                  final userApiResponse = UserApiResponse<List<UserApiData>>.fromJson(
                    responseData,
                    (json) {
                      if (json is List) {
                        return (json as List<dynamic>).map((userJson) => UserApiData.fromJson(userJson)).toList();
                      } else {
                        throw Exception('Expected List but got ${json.runtimeType}');
                      }
                    },
                  );
                  print('🔍 USER SERVICE: Parsed UserApiResponse - Success: ${userApiResponse.success}, Data count: ${userApiResponse.data?.length ?? 0}');
                  print('🔍 USER SERVICE: Message - AR: ${userApiResponse.message.ar}, EN: ${userApiResponse.message.en}');
                 
                  if (userApiResponse.success && userApiResponse.data != null) {
                    print('✅ USER SERVICE: Converting ${userApiResponse.data!.length} users from API format to User model...');
                    users = userApiResponse.data!.map((userApiData) => _convertToUser(userApiData)).toList();
                    print('✅ USER SERVICE: Successfully converted ${users.length} users from UserApiResponse');
                  } else {
                    print('❌ USER SERVICE: API response indicates failure - Success: ${userApiResponse.success}, Message: ${userApiResponse.message.en}');
                    _showErrorToast(context, userApiResponse.message.en);
                    return [];
                  }
               } catch (parseError) {
                 print('❌ USER SERVICE: Failed to parse as UserApiResponse: $parseError');
                 print('🔍 USER SERVICE: Attempting to extract users from any available fields...');
                 
                 // Try to find any list that might contain user data
                 for (final entry in responseData.entries) {
                   if (entry.value is List) {
                     print('🔍 USER SERVICE: Found list in field "${entry.key}" with ${(entry.value as List).length} items');
                     try {
                       final potentialUsers = (entry.value as List).map((item) {
                         if (item is Map<String, dynamic>) {
                           // Check if this looks like user data
                           if (item.containsKey('id') && item.containsKey('name') && item.containsKey('email')) {
                             print('🔍 USER SERVICE: Found potential user data: $item');
                             return _convertToUser(UserApiData.fromJson(item));
                           }
                         }
                         return null;
                       }).where((user) => user != null).cast<User>().toList();
                       
                       if (potentialUsers.isNotEmpty) {
                         print('✅ USER SERVICE: Successfully extracted ${potentialUsers.length} users from field "${entry.key}"');
                         users = potentialUsers;
                         break;
                       }
                     } catch (e) {
                       print('❌ USER SERVICE: Error processing field "${entry.key}": $e');
                     }
                   }
                 }
                 
                 if (users.isEmpty) {
                   print('❌ USER SERVICE: Could not extract users from any field');
                   throw parseError;
                 }
               }
             }
           } catch (e) {
             print('❌ USER SERVICE: Error parsing UserApiResponse: $e');
             print('🔍 USER SERVICE: Error details - Type: ${e.runtimeType}, Message: $e');
             _showErrorToast(context, 'خطأ في تحليل ردة الاستجابة من الخادم: ${e.toString()}');
             return [];
           }
        } else {
          print('❌ USER SERVICE: Unexpected response data type: ${responseData.runtimeType}');
          print('🔍 USER SERVICE: Raw response data: $responseData');
          
          // Try to extract any useful information from the response
          if (responseData != null) {
            print('🔍 USER SERVICE: Response data toString: ${responseData.toString()}');
            print('🔍 USER SERVICE: Response data runtimeType: ${responseData.runtimeType}');
            
            // If it's a string, try to parse it
            if (responseData is String) {
              try {
                final parsed = jsonDecode(responseData);
                print('🔍 USER SERVICE: Parsed string response: $parsed');
                print('🔍 USER SERVICE: Parsed type: ${parsed.runtimeType}');
              } catch (e) {
                print('🔍 USER SERVICE: Could not parse string response: $e');
              }
            }
          }
          
          _showErrorToast(context, 'تنسيق غير متوقع من الخادم');
          return [];
        }
        
        return users;
      } else {
        print('❌ USER SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 USER SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isAuthError(response)) {
          print('🔐 USER SERVICE: Authentication error detected, user needs to log in again');
          _showErrorToast(context, 'خطأ تسجيل الدخول: يرجى تسجيل الدخول مرة أخرى');
        } else {
          print('⚠️ USER SERVICE: Other error type: $errorType');
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return [];
      }
    } catch (e) {
      print('💥 USER SERVICE: Exception occurred while getting users: $e');
      print('💥 USER SERVICE: Exception type: ${e.runtimeType}');
      print('💥 USER SERVICE: Stack trace: ${StackTrace.current}');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return [];
    }
  }

  // Get single user by ID (using getAllUsers and filtering)
  static Future<User?> getUserById(BuildContext context, int userId) async {
    print('👥 USER SERVICE: ===== GETTING USER BY ID =====');
    print('🔍 USER SERVICE: Looking for user with ID: $userId');
    
    try {
      print('📡 USER SERVICE: Fetching all users to find specific user...');
      final allUsers = await getUsers(context);
      print('🔍 USER SERVICE: Found ${allUsers.length} total users, searching for ID: $userId');
      
      final user = allUsers.firstWhere((user) => user.id == userId);
      print('✅ USER SERVICE: User found - Name: ${user.name}, Email: ${user.email}');
      return user;
    } catch (e) {
      print('❌ USER SERVICE: Error getting user by ID: $e');
      if (e is StateError) {
        print('🔍 USER SERVICE: User with ID $userId not found in the list');
      }
      _showErrorToast(context, 'المستخدم غير موجود');
      return null;
    }
  }

  // Create new user
  static Future<User?> createUser(BuildContext context, User user) async {
    print('👥 USER SERVICE: ===== CREATING NEW USER =====');
    print('🔍 USER SERVICE: User details - Name: ${user.name}, Email: ${user.email}, Role: ${user.role}');
    print('🔍 USER SERVICE: Company ID: ${user.companyId}, Status: ${user.status ?? 'active'}');
    
    try {
      // Create UserCreateRequest from User model
      print('🔧 USER SERVICE: Creating UserCreateRequest from User model...');
      final createRequest = UserCreateRequest(
        name: user.name,
        email: user.email,
        password: user.password ?? '',
        role: user.getFirstRoleName(),
        companyId: user.companyId,
        status: user.status ?? 'active',
      );
      print('✅ USER SERVICE: UserCreateRequest created successfully');
      print('📤 USER SERVICE: Request payload: ${createRequest.toJson()}');

      print('🌐 USER SERVICE: Calling API endpoint: ${ApiEndpoints.createUser}');
      print('📡 USER SERVICE: Making POST request to create user...');
      final response = await ApiService.post(ApiEndpoints.createUser, body: createRequest.toJson());
      print('📡 USER SERVICE: Response received - Status: ${response.statusCode}, Body: ${response.body}');
      
      if (ApiService.isSuccessResponse(response)) {
        final responseData = jsonDecode(response.body);
        final userApiResponse = UserApiResponse<UserApiData>.fromJson(
          responseData,
          UserApiData.fromJson,
        );
        
        if (userApiResponse.success) {
          _showSuccessToast(context, userApiResponse.message.ar);
          // Convert UserApiData to User model
          if (userApiResponse.data != null) {
            final userApiData = userApiResponse.data!;
            final createdUser = User(
              id: userApiData.id,
              name: userApiData.name,
              email: userApiData.email,
              emailVerifiedAt: userApiData.emailVerifiedAt,
              createdAt: userApiData.createdAt ?? DateTime.now().toIso8601String(),
              updatedAt: userApiData.updatedAt ?? DateTime.now().toIso8601String(),
              companyId: userApiData.companyId,
              status: userApiData.status,
              company: userApiData.company,
              roles: userApiData.roles,
              role: userApiData.roles.isNotEmpty ? userApiData.roles.first.name : null,
            );
            return createdUser;
          }
          return null;
        } else {
          _showErrorToast(context, userApiResponse.message.ar);
          return null;
        }
      } else {
        print('❌ USER SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 USER SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isValidationError(response)) {
          print('⚠️ USER SERVICE: Validation error detected');
          _showErrorToast(context, 'خطأ تحقق: $errorMessage');
        } else if (ApiService.isAuthError(response)) {
          print('🔐 USER SERVICE: Authentication error detected, user needs to log in again');
          _showErrorToast(context, 'خطأ تسجيل الدخول: يرجى تسجيل الدخول مرة أخرى');
        } else {
          print('⚠️ USER SERVICE: Other error type: $errorType');
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return null;
      }
    } catch (e) {
      print('💥 USER SERVICE: Exception occurred while creating user: $e');
      print('💥 USER SERVICE: Exception type: ${e.runtimeType}');
      print('💥 USER SERVICE: Stack trace: ${StackTrace.current}');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return null;
    }
  }

  // Update existing user
  static Future<bool> updateUser(BuildContext context, User user) async {
    print('👥 USER SERVICE: ===== UPDATING EXISTING USER =====');
    print('🔍 USER SERVICE: User details - ID: ${user.id}, Name: ${user.name}, Email: ${user.email}');
    print('🔍 USER SERVICE: Role: ${user.role}, Company ID: ${user.companyId}, Status: ${user.status}');
    
    try {
      if (user.id == null) {
        print('❌ USER SERVICE: User ID is null, cannot update');
        _showErrorToast(context, 'معرف المستخدم مطلوب للتحديث');
        return false;
      }

      // Create UserUpdateRequest from User model
      print('🔧 USER SERVICE: Creating UserUpdateRequest from User model...');
      final updateRequest = UserUpdateRequest(
        id: user.id!,
        name: user.name,
        email: user.email,
        password: user.password,
        role: user.getFirstRoleName(),
        companyId: user.companyId,
        status: user.status,
      );
      print('✅ USER SERVICE: UserUpdateRequest created successfully');
      print('📤 USER SERVICE: Request payload: ${updateRequest.toJson()}');

      print('🌐 USER SERVICE: Calling API endpoint: ${ApiEndpoints.updateUser}');
      print('📡 USER SERVICE: Making POST request to update user...');
      final response = await ApiService.post(ApiEndpoints.updateUser, body: updateRequest.toJson());
      print('📡 USER SERVICE: Response received - Status: ${response.statusCode}, Body: ${response.body}');
      
      if (ApiService.isSuccessResponse(response)) {
        final responseData = jsonDecode(response.body);
        final userApiResponse = UserApiResponse<UserApiData>.fromJson(
          responseData,
          UserApiData.fromJson,
        );
        
        if (userApiResponse.success) {
          _showSuccessToast(context, userApiResponse.message.ar);
          return true;
        } else {
          _showErrorToast(context, userApiResponse.message.ar);
          return false;
        }
      } else {
        print('❌ USER SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 USER SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isValidationError(response)) {
          print('⚠️ USER SERVICE: Validation error detected');
          _showErrorToast(context, 'خطأ تحقق: $errorMessage');
        } else if (ApiService.isNotFoundError(response)) {
          print('🔍 USER SERVICE: User not found error detected');
          _showErrorToast(context, 'المستخدم غير موجود');
        } else if (ApiService.isAuthError(response)) {
          print('🔐 USER SERVICE: Authentication error detected, user needs to log in again');
          _showErrorToast(context, 'خطأ تسجيل الدخول: يرجى تسجيل الدخول مرة أخرى');
        } else {
          print('⚠️ USER SERVICE: Other error type: $errorType');
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return false;
      }
    } catch (e) {
      print('💥 USER SERVICE: Exception occurred while updating user: $e');
      print('💥 USER SERVICE: Exception type: ${e.runtimeType}');
      print('💥 USER SERVICE: Stack trace: ${StackTrace.current}');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Activate user
  static Future<bool> activateUser(BuildContext context, int userId) async {
    print('👥 USER SERVICE: ===== ACTIVATING USER =====');
    print('🔍 USER SERVICE: Activating user with ID: $userId');
    
    try {
      print('🔧 USER SERVICE: Creating UserStatusRequest...');
      final activateRequest = UserStatusRequest(userId: userId);
      print('📤 USER SERVICE: Request payload: ${activateRequest.toJson()}');
      
      print('🌐 USER SERVICE: Calling API endpoint: ${ApiEndpoints.activateUser}');
      print('📡 USER SERVICE: Making POST request to activate user...');
      final response = await ApiService.post(ApiEndpoints.activateUser, body: activateRequest.toJson());
      print('📡 USER SERVICE: Response received - Status: ${response.statusCode}, Body: ${response.body}');
      
      if (ApiService.isSuccessResponse(response)) {
        final responseData = jsonDecode(response.body);
        final userApiResponse = UserApiResponse<UserApiData>.fromJson(
          responseData,
          UserApiData.fromJson,
        );
        
        if (userApiResponse.success) {
          _showSuccessToast(context, userApiResponse.message.ar);
          return true;
        } else {
          _showErrorToast(context, userApiResponse.message.ar);
          return false;
        }
      } else {
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        
        if (ApiService.isNotFoundError(response)) {
          _showErrorToast(context, 'المستخدم غير موجود');
        } else if (ApiService.isAuthError(response)) {
          _showErrorToast(context, 'خطأ تسجيل الدخول: يرجى تسجيل الدخول مرة أخرى');
        } else {
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return false;
      }
    } catch (e) {
      print('💥 USER SERVICE: Exception occurred while activating user: $e');
      print('💥 USER SERVICE: Exception type: ${e.runtimeType}');
      print('💥 USER SERVICE: Stack trace: ${StackTrace.current}');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Deactivate user
  static Future<bool> deactivateUser(BuildContext context, int userId) async {
    print('👥 USER SERVICE: ===== DEACTIVATING USER =====');
    print('🔍 USER SERVICE: Deactivating user with ID: $userId');
    
    try {
      print('🔧 USER SERVICE: Creating UserStatusRequest...');
      final deactivateRequest = UserStatusRequest(userId: userId);
      print('📤 USER SERVICE: Request payload: ${deactivateRequest.toJson()}');
      
      print('🌐 USER SERVICE: Calling API endpoint: ${ApiEndpoints.deactivateUser}');
      print('📡 USER SERVICE: Making POST request to deactivate user...');
      final response = await ApiService.post(ApiEndpoints.deactivateUser, body: deactivateRequest.toJson());
      print('📡 USER SERVICE: Response received - Status: ${response.statusCode}, Body: ${response.body}');
      
      if (ApiService.isSuccessResponse(response)) {
        print('✅ USER SERVICE: API call successful, parsing response...');
        final responseData = jsonDecode(response.body);
        print('🔍 USER SERVICE: Parsed response data: $responseData');
        
        final userApiResponse = UserApiResponse<UserApiData>.fromJson(
          responseData,
          UserApiData.fromJson,
        );
        print('🔍 USER SERVICE: Parsed UserApiResponse - Success: ${userApiResponse.success}, Message: ${userApiResponse.message.en}');
        
        if (userApiResponse.success) {
          print('✅ USER SERVICE: User deactivated successfully on server');
          _showSuccessToast(context, userApiResponse.message.ar);
          return true;
        } else {
          print('❌ USER SERVICE: Server returned success=false - Message: ${userApiResponse.message.ar}');
          _showErrorToast(context, userApiResponse.message.ar);
          return false;
        }
      } else {
        print('❌ USER SERVICE: API call failed, handling error response...');
        final errorMessage = ApiService.handleErrorResponse(response);
        final errorType = ApiService.getErrorType(response);
        print('🔍 USER SERVICE: Error details - Type: $errorType, Message: $errorMessage');
        
        if (ApiService.isNotFoundError(response)) {
          print('🔍 USER SERVICE: User not found error detected');
          _showErrorToast(context, 'المستخدم غير موجود');
        } else if (ApiService.isAuthError(response)) {
          print('🔐 USER SERVICE: Authentication error detected, user needs to log in again');
          _showErrorToast(context, 'خطأ تسجيل الدخول: يرجى تسجيل الدخول مرة أخرى');
        } else {
          print('⚠️ USER SERVICE: Other error type: $errorType');
          _showErrorToast(context, '$errorType: $errorMessage');
        }
        return false;
      }
    } catch (e) {
      print('💥 USER SERVICE: Exception occurred while deactivating user: $e');
      print('💥 USER SERVICE: Exception type: ${e.runtimeType}');
      print('💥 USER SERVICE: Stack trace: ${StackTrace.current}');
      _showErrorToast(context, 'خطأ في الشبكة: ${e.toString()}');
      return false;
    }
  }

  // Validate user data before sending to API
  static String? validateUserData(User user) {
    if (user.name.trim().isEmpty) {
      print('❌ USER SERVICE: Validation failed - Name is empty');
      return 'الاسم مطلوب';
    }
    
    if (user.email.trim().isEmpty) {
      print('❌ USER SERVICE: Validation failed - Email is empty');
      return 'البريد الإلكتروني مطلوب';
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(user.email)) {
      print('❌ USER SERVICE: Validation failed - Invalid email format: ${user.email}');
      return 'الرجاء إدخال بريد إلكتروني صالح';
    }
    
    return null;
  }

  // Validate if user status can be changed
  static String? validateStatusChange(User user) {
    if (user.isSystemAdministrator) {
      print('❌ USER SERVICE: Status change validation failed - User is system administrator');
      return 'لا يمكن تغيير حالة مدير النظام';
    }
    
    if (!user.canChangeStatus) {
      print('❌ USER SERVICE: Status change validation failed - User status cannot be changed');
      return 'لا يمكن تغيير حالة هذا المستخدم';
    }
    
    return null;
  }

  // Check if user can be activated
  static String? canActivateUser(User user) {
    if (user.isSystemAdministrator) {
      return 'لا يمكن تفعيل مدير النظام';
    }
    
    if (user.isActive) {
      return 'المستخدم نشط بالفعل';
    }
    
    return null;
  }

  // Check if user can be deactivated
  static String? canDeactivateUser(User user) {
    if (user.isSystemAdministrator) {
      return 'لا يمكن إلغاء تفعيل مدير النظام';
    }
    
    if (user.isInactive) {
      return 'المستخدم غير نشط بالفعل';
    }
    
    return null;
  }

  // Get default avatar path
  static String getDefaultAvatar() {
    print('🖼️ USER SERVICE: Getting default avatar path');
    return 'assets/user/user-01.png';
  }

  // Helper method to convert UserApiData to User model
  static User _convertToUser(UserApiData userApiData) {
    print('🔄 USER SERVICE: Converting UserApiData to User model...');
    print('🔍 USER SERVICE: Source data - ID: ${userApiData.id}, Name: ${userApiData.name}, Email: ${userApiData.email}');
    print('🔍 USER SERVICE: Roles count: ${userApiData.roles.length}, Company ID: ${userApiData.companyId}, Status: ${userApiData.status}');
    print('🔍 USER SERVICE: Company data: ${userApiData.company}');
    print('🔍 USER SERVICE: Created at: ${userApiData.createdAt}, Updated at: ${userApiData.updatedAt}');
    
    try {
      // Get the first role name for backward compatibility
      String? firstRoleName;
      if (userApiData.roles.isNotEmpty) {
        firstRoleName = userApiData.roles.first.name;
      }
      
      final user = User(
        id: userApiData.id,
        name: userApiData.name,
        email: userApiData.email,
        password: null, // Password not returned by API
        role: firstRoleName, // Use first role for backward compatibility
        roles: userApiData.roles, // Use the roles array from API
        emailVerifiedAt: userApiData.emailVerifiedAt,
        createdAt: userApiData.createdAt ?? '',
        updatedAt: userApiData.updatedAt ?? '',
        companyId: userApiData.companyId,
        status: userApiData.status,
        company: userApiData.company,
      );
      
      print('✅ USER SERVICE: User model created successfully - ID: ${user.id}, Name: ${user.name}, Roles: ${user.roles.length}');
      return user;
    } catch (e) {
      print('💥 USER SERVICE: Error creating User model: $e');
      print('💥 USER SERVICE: Error type: ${e.runtimeType}');
      print('💥 USER SERVICE: UserApiData details: ${userApiData.toJson()}');
      rethrow;
    }
  }
}
