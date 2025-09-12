import 'package:flutter/material.dart';

class ValidationHelper {
  /// Validates training plan data according to server-side validation rules
  static Map<String, String> validateTrainingPlanData({
    required int? year,
    required String? title,
    String? description,
    String? status,
    int? id,
    bool isUpdate = false,
  }) {
    final errors = <String, String>{};

    // Validate ID for update operations
    if (isUpdate && id == null) {
      errors['id'] = 'Training plan ID is required';
    }

    // Validate year
    if (year == null) {
      errors['year'] = 'Training plan year is required';
    } else {
      if (year < 2020) {
        errors['year'] = 'Training plan year must be at least 2020';
      } else if (year > 2050) {
        errors['year'] = 'Training plan year cannot exceed 2050';
      }
    }

    // Validate title
    if (title == null || title.trim().isEmpty) {
      errors['title'] = 'Training plan title is required';
    } else {
      if (title.trim().length > 255) {
        errors['title'] = 'Training plan title cannot exceed 255 characters';
      }
    }

    // Validate description (optional but must be string if provided)
    if (description != null && description.trim().isNotEmpty) {
      // Description is optional, no additional validation needed
    }

    // Validate status
    if (status != null) {
      if (!['draft', 'submitted'].contains(status)) {
        errors['status'] = 'Status must be one of: draft, submitted';
      }
    }

    return errors;
  }

  /// Validates year input specifically
  static String? validateYear(dynamic value) {
    if (value == null) {
      return 'Please select a year';
    }
    final year = value is int ? value : int.tryParse(value.toString());
    if (year == null) {
      return 'Please select a valid year';
    }
    if (year < 2020) {
      return 'Year must be at least 2020';
    }
    if (year > 2050) {
      return 'Year cannot exceed 2050';
    }
    return null;
  }

  /// Validates title input specifically
  static String? validateTitle(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Please enter a title';
    }
    final title = value.toString().trim();
    if (title.length > 255) {
      return 'Title must be less than 255 characters';
    }
    return null;
  }

  /// Validates description input specifically
  static String? validateDescription(dynamic value) {
    // Description is optional, no validation needed
    return null;
  }

  /// Validates status input specifically
  static String? validateStatus(dynamic value) {
    if (value != null && !['draft', 'submitted'].contains(value.toString())) {
      return 'Status must be one of: draft, submitted';
    }
    return null;
  }

  /// Validates that a training plan can be edited
  static String? validateCanEdit(String status) {
    if (status != 'draft') {
      return 'Only draft training plans can be edited';
    }
    return null;
  }

  /// Validates that a training plan can be submitted
  static String? validateCanSubmit(String status) {
    if (status != 'draft') {
      return 'Only draft training plans can be submitted';
    }
    return null;
  }


  /// Validates year uniqueness (client-side check)
  static String? validateYearUniqueness(int year, List<int> existingYears, {int? excludeId}) {
    if (existingYears.contains(year)) {
      return 'A training plan for year $year already exists. Please choose a different year.';
    }
    return null;
  }

  /// Validates form submission based on business rules
  static Map<String, String> validateFormSubmission({
    required String status,
    required bool canEdit,
    required bool canSubmit,
  }) {
    final errors = <String, String>{};

    if (status == 'submitted' && !canSubmit) {
      errors['status'] = 'This training plan cannot be submitted in its current state';
    }

    if (status != 'draft' && !canEdit) {
      errors['status'] = 'This training plan cannot be edited in its current state';
    }

    return errors;
  }

  /// Validates API request data before sending
  static Map<String, String> validateApiRequest({
    required Map<String, dynamic> data,
    required bool isUpdate,
  }) {
    final errors = <String, String>{};

    // Validate required fields for create operation
    if (!isUpdate) {
      if (!data.containsKey('year') || data['year'] == null) {
        errors['year'] = 'Year is required';
      }
      if (!data.containsKey('title') || data['title'] == null || data['title'].toString().trim().isEmpty) {
        errors['title'] = 'Title is required';
      }
    }

    // Validate field types and constraints
    if (data.containsKey('year') && data['year'] != null) {
      final year = data['year'];
      if (year is! int) {
        errors['year'] = 'Year must be a valid integer';
      } else if (year < 2020 || year > 2050) {
        errors['year'] = 'Year must be between 2020 and 2050';
      }
    }

    if (data.containsKey('title') && data['title'] != null) {
      final title = data['title'].toString();
      if (title.trim().isEmpty) {
        errors['title'] = 'Title cannot be empty';
      } else if (title.length > 255) {
        errors['title'] = 'Title cannot exceed 255 characters';
      }
    }

    if (data.containsKey('status') && data['status'] != null) {
      final status = data['status'].toString();
      if (!['draft', 'submitted'].contains(status)) {
        errors['status'] = 'Status must be one of: draft, submitted';
      }
    }

    return errors;
  }

  /// Shows validation errors in a user-friendly format
  static void showValidationErrors(BuildContext context, Map<String, String> errors) {
    if (errors.isEmpty) return;

    final errorMessages = errors.values.toList();
    final message = errorMessages.length == 1 
        ? errorMessages.first 
        : 'Please fix the following errors:\n• ${errorMessages.join('\n• ')}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Validates training plan status transitions
  static bool isValidStatusTransition(String fromStatus, String toStatus) {
    // Only allow draft → submitted transition
    if (fromStatus == 'draft' && toStatus == 'submitted') {
      return true;
    }
    
    // No other transitions are allowed
    return false;
  }

  /// Gets available status options based on current status
  static List<Map<String, String>> getAvailableStatusOptions(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return [
          {'value': 'draft', 'label': 'Draft'},
          {'value': 'submitted', 'label': 'Submitted (Use Submit button)'},
        ];
      case 'submitted':
        return [
          {'value': 'submitted', 'label': 'Submitted (Cannot be changed)'},
        ];
      default:
        return [
          {'value': currentStatus, 'label': currentStatus.toUpperCase()},
        ];
    }
  }

  /// Validates business rules for training plan operations
  static Map<String, String> validateBusinessRules({
    required String operation,
    required String currentStatus,
    required bool hasPermission,
  }) {
    final errors = <String, String>{};

    if (!hasPermission) {
      errors['permission'] = 'You do not have permission to perform this operation';
      return errors;
    }

    switch (operation) {
      case 'edit':
        if (currentStatus != 'draft') {
          errors['status'] = 'Only draft training plans can be edited';
        }
        break;
      case 'submit':
        if (currentStatus != 'draft') {
          errors['status'] = 'Only draft training plans can be submitted';
        }
        break;
      default:
        errors['operation'] = 'Invalid operation';
    }

    return errors;
  }
}
