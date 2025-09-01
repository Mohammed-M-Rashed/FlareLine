import 'package:flutter_test/flutter_test.dart';
import 'package:flareline/core/models/training_center_branch_model.dart';
import 'package:flareline/core/services/training_center_branch_service.dart';

void main() {
  group('TrainingCenterBranch Model Tests', () {
    test('should create TrainingCenterBranch from JSON', () {
      final json = {
        'id': 1,
        'name': 'Main Branch',
        'training_center_id': 1,
        'training_center_name': 'Test Center',
        'address': '123 Test Street',
        'phone': '+1234567890',
        'status': 'active',
        'lat': 40.7128,
        'long': -74.0060,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final branch = TrainingCenterBranch.fromJson(json);

      expect(branch.id, 1);
      expect(branch.name, 'Main Branch');
      expect(branch.trainingCenterId, 1);
      expect(branch.trainingCenterName, 'Test Center');
      expect(branch.address, '123 Test Street');
      expect(branch.phone, '+1234567890');
      expect(branch.status, 'active');
      expect(branch.lat, 40.7128);
      expect(branch.long, -74.0060);
      expect(branch.createdAt, isA<DateTime>());
      expect(branch.updatedAt, isA<DateTime>());
    });

    test('should convert TrainingCenterBranch to JSON', () {
      final branch = TrainingCenterBranch(
        id: 1,
        name: 'Main Branch',
        trainingCenterId: 1,
        trainingCenterName: 'Test Center',
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
        lat: 40.7128,
        long: -74.0060,
      );

      final json = branch.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Main Branch');
      expect(json['training_center_id'], 1);
      expect(json['address'], '123 Test Street');
      expect(json['phone'], '+1234567890');
      expect(json['status'], 'active');
      expect(json['lat'], 40.7128);
      expect(json['long'], -74.0060);
    });

    test('should create TrainingCenterBranchCreateRequest', () {
      final request = TrainingCenterBranchCreateRequest(
        name: 'New Branch',
        trainingCenterId: 1,
        address: '456 New Street',
        phone: '+0987654321',
        status: 'active',
        lat: 35.6762,
        long: 139.6503,
      );

      final json = request.toJson();

      expect(json['name'], 'New Branch');
      expect(json['training_center_id'], 1);
      expect(json['address'], '456 New Street');
      expect(json['phone'], '+0987654321');
      expect(json['status'], 'active');
      expect(json['lat'], 35.6762);
      expect(json['long'], 139.6503);
    });

    test('should create TrainingCenterBranchUpdateRequest', () {
      final request = TrainingCenterBranchUpdateRequest(
        id: 1,
        name: 'Updated Branch',
        address: '789 Updated Street',
      );

      final json = request.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Updated Branch');
      expect(json['address'], '789 Updated Street');
      expect(json['training_center_id'], isNull);
      expect(json['phone'], isNull);
      expect(json['status'], isNull);
      expect(json['lat'], isNull);
      expect(json['long'], isNull);
    });

    test('should get full address with coordinates', () {
      final branch = TrainingCenterBranch(
        name: 'Test Branch',
        trainingCenterId: 1,
        trainingCenterName: 'Test Center',
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
        lat: 40.7128,
        long: -74.0060,
      );

      expect(branch.fullAddress, '123 Test Street (40.7128000, -74.0060000)');
      expect(branch.hasCoordinates, true);
    });

    test('should get address without coordinates', () {
      final branch = TrainingCenterBranch(
        name: 'Test Branch',
        trainingCenterId: 1,
        trainingCenterName: 'Test Center',
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
      );

      expect(branch.fullAddress, '123 Test Street');
      expect(branch.hasCoordinates, false);
    });

    test('should check status correctly', () {
      final activeBranch = TrainingCenterBranch(
        name: 'Active Branch',
        trainingCenterId: 1,
        trainingCenterName: 'Test Center',
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
      );

      final inactiveBranch = TrainingCenterBranch(
        name: 'Inactive Branch',
        trainingCenterId: 1,
        trainingCenterName: 'Test Center',
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'inactive',
      );

      expect(activeBranch.isActive, true);
      expect(activeBranch.isInactive, false);
      expect(inactiveBranch.isActive, false);
      expect(inactiveBranch.isInactive, true);
    });
  });

  group('TrainingCenterBranchService Validation Tests', () {
    test('should validate correct data', () {
      final error = TrainingCenterBranchService.validateTrainingCenterBranchData(
        name: 'Test Branch',
        trainingCenterId: 1,
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
        lat: 40.7128,
        long: -74.0060,
      );

      expect(error, isNull);
    });

    test('should validate data without coordinates', () {
      final error = TrainingCenterBranchService.validateTrainingCenterBranchData(
        name: 'Test Branch',
        trainingCenterId: 1,
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
      );

      expect(error, isNull);
    });

    test('should reject empty name', () {
      final error = TrainingCenterBranchService.validateTrainingCenterBranchData(
        name: '',
        trainingCenterId: 1,
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
      );

      expect(error, 'Branch name is required');
    });

    test('should reject invalid latitude', () {
      final error = TrainingCenterBranchService.validateTrainingCenterBranchData(
        name: 'Test Branch',
        trainingCenterId: 1,
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
        lat: 100.0, // Invalid latitude
        long: -74.0060,
      );

      expect(error, 'Latitude must be between -90 and 90 degrees');
    });

    test('should reject invalid longitude', () {
      final error = TrainingCenterBranchService.validateTrainingCenterBranchData(
        name: 'Test Branch',
        trainingCenterId: 1,
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'active',
        lat: 40.7128,
        long: 200.0, // Invalid longitude
      );

      expect(error, 'Longitude must be between -180 and 180 degrees');
    });

    test('should reject invalid status', () {
      final error = TrainingCenterBranchService.validateTrainingCenterBranchData(
        name: 'Test Branch',
        trainingCenterId: 1,
        address: '123 Test Street',
        phone: '+1234567890',
        status: 'invalid_status',
      );

      expect(error, 'Status must be either active or inactive');
    });
  });
}
