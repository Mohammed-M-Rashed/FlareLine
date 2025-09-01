import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:flareline/core/services/trainer_service.dart';
import 'package:flareline/core/models/trainer_model.dart';
import 'package:flareline/core/auth/auth_provider.dart';

// Generate mocks
@GenerateMocks([http.Client, AuthController])
import 'trainer_api_integration_test.mocks.dart';

void main() {
  group('Trainer API Integration Tests', () {
    late MockClient mockHttpClient;
    late MockAuthController mockAuthController;

    setUp(() {
      mockHttpClient = MockClient();
      mockAuthController = MockAuthController();
      
      // Setup GetX
      Get.put<AuthController>(mockAuthController);
    });

    tearDown(() {
      Get.reset();
    });

    group('Trainer Model Tests', () {
      test('should create trainer from JSON', () {
        final json = {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'bio': 'Experienced software developer',
          'qualifications': 'Bachelor in Computer Science',
          'years_experience': 5,
          'specializations': ['Software Development', 'Web Development'],
          'certifications': ['AWS Certified Developer'],
          'location': 'New York',
          'status': 'pending',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        };

        final trainer = Trainer.fromJson(json);

        expect(trainer.id, 1);
        expect(trainer.name, 'John Doe');
        expect(trainer.email, 'john@example.com');
        expect(trainer.phone, '+1234567890');
        expect(trainer.bio, 'Experienced software developer');
        expect(trainer.qualifications, 'Bachelor in Computer Science');
        expect(trainer.yearsExperience, 5);
        expect(trainer.specializations, ['Software Development', 'Web Development']);
        expect(trainer.certifications, ['AWS Certified Developer']);
        expect(trainer.location, 'New York');
        expect(trainer.status, 'pending');
        expect(trainer.isPending, true);
        expect(trainer.isApproved, false);
        expect(trainer.isRejected, false);
      });

      test('should convert trainer to JSON', () {
        final trainer = Trainer(
          id: 1,
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '+0987654321',
          bio: 'Data scientist',
          qualifications: 'PhD in Statistics',
          yearsExperience: 8,
          specializations: ['Data Science', 'Machine Learning'],
          certifications: ['Google Cloud Professional Data Engineer'],
          location: 'San Francisco',
          status: 'approved',
        );

        final json = trainer.toJson();

        expect(json['id'], 1);
        expect(json['name'], 'Jane Smith');
        expect(json['email'], 'jane@example.com');
        expect(json['phone'], '+0987654321');
        expect(json['bio'], 'Data scientist');
        expect(json['qualifications'], 'PhD in Statistics');
        expect(json['years_experience'], 8);
        expect(json['specializations'], ['Data Science', 'Machine Learning']);
        expect(json['certifications'], ['Google Cloud Professional Data Engineer']);
        expect(json['location'], 'San Francisco');
        expect(json['status'], 'approved');
      });

      test('should create trainer create request', () {
        final request = TrainerCreateRequest(
          name: 'Bob Wilson',
          email: 'bob@example.com',
          phone: '+1122334455',
          bio: 'DevOps engineer',
          qualifications: 'Master in IT',
          yearsExperience: 3,
          specializations: ['DevOps', 'Cloud Computing'],
          certifications: ['Docker Certified Associate'],
          location: 'Austin',
        );

        final json = request.toJson();

        expect(json['name'], 'Bob Wilson');
        expect(json['email'], 'bob@example.com');
        expect(json['phone'], '+1122334455');
        expect(json['bio'], 'DevOps engineer');
        expect(json['qualifications'], 'Master in IT');
        expect(json['years_experience'], 3);
        expect(json['specializations'], ['DevOps', 'Cloud Computing']);
        expect(json['certifications'], ['Docker Certified Associate']);
        expect(json['location'], 'Austin');
      });

      test('should create trainer update request', () {
        final request = TrainerUpdateRequest(
          id: 1,
          name: 'Updated Name',
          email: 'updated@example.com',
          yearsExperience: 10,
        );

        final json = request.toJson();

        expect(json['id'], 1);
        expect(json['name'], 'Updated Name');
        expect(json['email'], 'updated@example.com');
        expect(json['years_experience'], 10);
        expect(json.containsKey('phone'), false);
        expect(json.containsKey('bio'), false);
      });

      test('should create trainer status request', () {
        final request = TrainerStatusRequest(id: 1);
        final json = request.toJson();

        expect(json['id'], 1);
      });
    });

    group('Trainer Response Models Tests', () {
      test('should create trainer list response from JSON', () {
        final json = {
          'data': [
            {
              'id': 1,
              'name': 'Trainer 1',
              'email': 'trainer1@example.com',
              'phone': '+1111111111',
              'specializations': ['Web Development'],
              'status': 'pending',
            },
            {
              'id': 2,
              'name': 'Trainer 2',
              'email': 'trainer2@example.com',
              'phone': '+2222222222',
              'specializations': ['Data Science'],
              'status': 'approved',
            },
          ],
          'm_ar': 'تم جلب المدربين بنجاح',
          'm_en': 'Trainers retrieved successfully',
          'status_code': 200,
        };

        final response = TrainerListResponse.fromJson(json);

        expect(response.data.length, 2);
        expect(response.data[0].name, 'Trainer 1');
        expect(response.data[1].name, 'Trainer 2');
        expect(response.mAr, 'تم جلب المدربين بنجاح');
        expect(response.mEn, 'Trainers retrieved successfully');
        expect(response.statusCode, 200);
        expect(response.success, true);
        expect(response.messageAr, 'تم جلب المدربين بنجاح');
        expect(response.messageEn, 'Trainers retrieved successfully');
      });

      test('should create trainer response from JSON', () {
        final json = {
          'data': {
            'id': 1,
            'name': 'Single Trainer',
            'email': 'single@example.com',
            'phone': '+3333333333',
            'specializations': ['Mobile Development'],
            'status': 'rejected',
          },
          'm_ar': 'تم إنشاء المدرب بنجاح',
          'm_en': 'Trainer created successfully',
          'status_code': 201,
        };

        final response = TrainerResponse.fromJson(json);

        expect(response.data?.name, 'Single Trainer');
        expect(response.data?.email, 'single@example.com');
        expect(response.data?.status, 'rejected');
        expect(response.mAr, 'تم إنشاء المدرب بنجاح');
        expect(response.mEn, 'Trainer created successfully');
        expect(response.statusCode, 201);
        expect(response.success, true);
        expect(response.messageAr, 'تم إنشاء المدرب بنجاح');
        expect(response.messageEn, 'Trainer created successfully');
      });
    });

    group('Trainer Service Permission Tests', () {
      test('should return false when user has no roles', () {
        when(mockAuthController.userData).thenReturn(null);

        final hasPermission = TrainerService.hasTrainerManagementPermission();

        expect(hasPermission, false);
      });

      test('should return false when user has no system_administrator role', () {
        final mockUser = MockUser();
        when(mockUser.roles).thenReturn([
          MockRole()..name = 'user',
          MockRole()..name = 'manager',
        ]);
        when(mockAuthController.userData).thenReturn(mockUser);

        final hasPermission = TrainerService.hasTrainerManagementPermission();

        expect(hasPermission, false);
      });

      test('should return true when user has system_administrator role', () {
        final mockUser = MockUser();
        when(mockUser.roles).thenReturn([
          MockRole()..name = 'user',
          MockRole()..name = 'system_administrator',
        ]);
        when(mockAuthController.userData).thenReturn(mockUser);

        final hasPermission = TrainerService.hasTrainerManagementPermission();

        expect(hasPermission, true);
      });
    });

    group('Trainer Service Validation Tests', () {
      test('should return null for valid data', () {
        final error = TrainerService.validateTrainerData(
          name: 'Valid Name',
          email: 'valid@example.com',
          phone: '+1234567890',
          specializations: ['Web Development'],
          yearsExperience: 5,
        );

        expect(error, null);
      });

      test('should return error for empty name', () {
        final error = TrainerService.validateTrainerData(
          name: '',
          email: 'valid@example.com',
          phone: '+1234567890',
          specializations: ['Web Development'],
        );

        expect(error, 'Name is required');
      });

      test('should return error for invalid email', () {
        final error = TrainerService.validateTrainerData(
          name: 'Valid Name',
          email: 'invalid-email',
          phone: '+1234567890',
          specializations: ['Web Development'],
        );

        expect(error, 'Invalid email format');
      });

      test('should return error for empty phone', () {
        final error = TrainerService.validateTrainerData(
          name: 'Valid Name',
          email: 'valid@example.com',
          phone: '',
          specializations: ['Web Development'],
        );

        expect(error, 'Phone is required');
      });

      test('should return error for empty specializations', () {
        final error = TrainerService.validateTrainerData(
          name: 'Valid Name',
          email: 'valid@example.com',
          phone: '+1234567890',
          specializations: [],
        );

        expect(error, 'Specializations are required');
      });

      test('should return error for invalid years of experience', () {
        final error = TrainerService.validateTrainerData(
          name: 'Valid Name',
          email: 'valid@example.com',
          phone: '+1234567890',
          specializations: ['Web Development'],
          yearsExperience: 60,
        );

        expect(error, 'Years of experience must be between 0 and 50');
      });

      test('should return error for negative years of experience', () {
        final error = TrainerService.validateTrainerData(
          name: 'Valid Name',
          email: 'valid@example.com',
          phone: '+1234567890',
          specializations: ['Web Development'],
          yearsExperience: -5,
        );

        expect(error, 'Years of experience must be between 0 and 50');
      });
    });

    group('Trainer Status Management Tests', () {
      test('should handle pending status correctly', () {
        final trainer = Trainer(
          name: 'Test Trainer',
          email: 'test@example.com',
          phone: '+1234567890',
          specializations: ['Test'],
          status: 'pending',
        );

        expect(trainer.isPending, true);
        expect(trainer.isApproved, false);
        expect(trainer.isRejected, false);
        expect(trainer.statusDisplay, 'Pending');
        expect(trainer.statusColor, Colors.orange);
      });

      test('should handle approved status correctly', () {
        final trainer = Trainer(
          name: 'Test Trainer',
          email: 'test@example.com',
          phone: '+1234567890',
          specializations: ['Test'],
          status: 'approved',
        );

        expect(trainer.isPending, false);
        expect(trainer.isApproved, true);
        expect(trainer.isRejected, false);
        expect(trainer.statusDisplay, 'Approved');
        expect(trainer.statusColor, Colors.green);
      });

      test('should handle rejected status correctly', () {
        final trainer = Trainer(
          name: 'Test Trainer',
          email: 'test@example.com',
          phone: '+1234567890',
          specializations: ['Test'],
          status: 'rejected',
        );

        expect(trainer.isPending, false);
        expect(trainer.isApproved, false);
        expect(trainer.isRejected, true);
        expect(trainer.statusDisplay, 'Rejected');
        expect(trainer.statusColor, Colors.red);
      });
    });
  });
}

// Mock classes for testing
class MockUser extends Mock {
  List<MockRole> get roles => [];
}

class MockRole extends Mock {
  String get name => '';
}
