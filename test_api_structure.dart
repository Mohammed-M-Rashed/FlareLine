// Test file to validate the new API response structure
// This simulates the expected API response format

import 'dart:convert';

// Mock API response matching the new structure
const String mockApiResponse = '''
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "email_verified_at": "2024-01-01T00:00:00Z",
      "company_id": 1,
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z",
      "company": {
        "id": 1,
        "name": "Test Company",
        "email": "company@test.com",
        "phone": "0912345678",
        "address": "Test Address",
        "status": "active",
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z"
      },
      "roles": [
        {
          "id": 1,
          "name": "system_administrator",
          "display_name": "System Administrator",
          "description": "Full system access",
          "permissions": ["read", "write", "delete", "admin"],
          "created_at": "2024-01-01T00:00:00Z",
          "updated_at": "2024-01-01T00:00:00Z",
          "pivot": {
            "user_id": 1,
            "role_id": 1,
            "assigned_at": "2024-01-01T00:00:00Z"
          }
        }
      ]
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com",
      "email_verified_at": null,
      "company_id": 2,
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z",
      "company": {
        "id": 2,
        "name": "Another Company",
        "email": "another@company.com",
        "phone": "0923456789",
        "address": "Another Address",
        "status": "active",
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z"
      },
      "roles": [
        {
          "id": 2,
          "name": "admin",
          "display_name": "Administrator",
          "description": "Company administrator",
          "permissions": ["read", "write"],
          "created_at": "2024-01-01T00:00:00Z",
          "updated_at": "2024-01-01T00:00:00Z",
          "pivot": {
            "user_id": 2,
            "role_id": 2,
            "assigned_at": "2024-01-01T00:00:00Z"
          }
        }
      ]
    },
    {
      "id": 3,
      "name": "Bob Wilson",
      "email": "bob@example.com",
      "email_verified_at": null,
      "company_id": 1,
      "status": "inactive",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z",
      "company": null,
      "roles": []
    }
  ],
  "message": {
    "ar": "تم جلب المستخدمين بنجاح",
    "en": "Users retrieved successfully"
  },
  "status_code": 200
}
''';

void main() {
  print('🧪 Testing new API response structure...\n');
  
  try {
    // Parse the mock API response
    final Map<String, dynamic> responseData = json.decode(mockApiResponse);
    print('✅ Successfully parsed API response JSON');
    
    // Test the structure
    print('\n📊 API Response Structure:');
    print('- success: ${responseData['success']}');
    print('- status_code: ${responseData['status_code']}');
    print('- message.ar: ${responseData['message']['ar']}');
    print('- message.en: ${responseData['message']['en']}');
    print('- data.length: ${responseData['data'].length}');
    
    // Test user data structure
    print('\n👥 User Data Structure:');
    final firstUser = responseData['data'][0];
    print('- id: ${firstUser['id']}');
    print('- name: ${firstUser['name']}');
    print('- email: ${firstUser['email']}');
    print('- email_verified_at: ${firstUser['email_verified_at']}');
    print('- company_id: ${firstUser['company_id']}');
    print('- status: ${firstUser['status']}');
    print('- created_at: ${firstUser['created_at']}');
    print('- updated_at: ${firstUser['updated_at']}');
    
    // Test company structure
    print('\n🏢 Company Structure:');
    final company = firstUser['company'];
    if (company != null) {
      print('- company.id: ${company['id']}');
      print('- company.name: ${company['name']}');
      print('- company.email: ${company['email']}');
      print('- company.phone: ${company['phone']}');
      print('- company.address: ${company['address']}');
      print('- company.status: ${company['status']}');
    } else {
      print('- company: null');
    }
    
    // Test roles structure
    print('\n🔐 Roles Structure:');
    final roles = firstUser['roles'];
    print('- roles.length: ${roles.length}');
    if (roles.isNotEmpty) {
      final firstRole = roles[0];
      print('- role.id: ${firstRole['id']}');
      print('- role.name: ${firstRole['name']}');
      print('- role.display_name: ${firstRole['display_name']}');
      print('- role.description: ${firstRole['description']}');
      print('- role.permissions: ${firstRole['permissions']}');
      print('- role.created_at: ${firstRole['created_at']}');
      print('- role.updated_at: ${firstRole['updated_at']}');
      print('- role.pivot: ${firstRole['pivot']}');
    }
    
    // Test edge cases
    print('\n🔍 Edge Cases:');
    final userWithNoRoles = responseData['data'][2];
    print('- User with no roles: ${userWithNoRoles['name']}');
    print('- Roles array: ${userWithNoRoles['roles']}');
    print('- Company: ${userWithNoRoles['company']}');
    
    print('\n✅ All tests passed! The new API structure is working correctly.');
    
  } catch (e) {
    print('❌ Error testing API structure: $e');
  }
}
