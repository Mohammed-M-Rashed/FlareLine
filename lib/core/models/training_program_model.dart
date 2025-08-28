import 'package:flutter/material.dart';

class TrainingProgram {
  final int? id;
  final String title;
  final int courseId;
  final int trainingCenterId;
  final int specializationId;
  final int seats;
  final String startDate;
  final String endDate;
  final String status;
  final dynamic createdBy; // Can be int or User object
  final String? createdAt;
  final String? updatedAt;
  final Course? course;
  final TrainingCenter? trainingCenter;
  final Specialization? specialization;

  TrainingProgram({
    this.id,
    required this.title,
    required this.courseId,
    required this.trainingCenterId,
    required this.specializationId,
    required this.seats,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.course,
    this.trainingCenter,
    this.specialization,
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      id: json['id'],
      title: json['title'],
      courseId: json['course_id'],
      trainingCenterId: json['training_center_id'],
      specializationId: json['specialization_id'],
      seats: json['seats'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      createdBy: json['created_by'], // Can be int or User object
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      course: json['course'] != null ? Course.fromJson(json['course']) : null,
      trainingCenter: json['training_center'] != null ? TrainingCenter.fromJson(json['training_center']) : null,
      specialization: json['specialization'] != null ? Specialization.fromJson(json['specialization']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_id': courseId,
      'training_center_id': trainingCenterId,
      'specialization_id': specializationId,
      'seats': seats,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'created_by': createdBy is User ? (createdBy as User).id : createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'course': course?.toJson(),
      'training_center': trainingCenter?.toJson(),
      'specialization': specialization?.toJson(),
    };
  }

  TrainingProgram copyWith({
    int? id,
    String? title,
    int? courseId,
    int? trainingCenterId,
    int? specializationId,
    int? seats,
    String? startDate,
    String? endDate,
    String? status,
    dynamic createdBy,
    String? createdAt,
    String? updatedAt,
    Course? course,
    TrainingCenter? trainingCenter,
    Specialization? specialization,
  }) {
    return TrainingProgram(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      trainingCenterId: trainingCenterId ?? this.trainingCenterId,
      specializationId: specializationId ?? this.specializationId,
      seats: seats ?? this.seats,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      course: course ?? this.course,
      trainingCenter: trainingCenter ?? this.trainingCenter,
      specialization: specialization ?? this.specialization,
    );
  }

  // Helper methods
  DateTime? get startDateTime => DateTime.tryParse(startDate);
  DateTime? get endDateTime => DateTime.tryParse(endDate);
  DateTime? get createdDateTime => createdAt != null ? DateTime.tryParse(createdAt!) : null;
  DateTime? get updatedDateTime => updatedAt != null ? DateTime.tryParse(updatedAt!) : null;

  String get formattedStartDate {
    final date = startDateTime;
    if (date == null) return startDate;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get formattedEndDate {
    final date = endDateTime;
    if (date == null) return endDate;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get formattedCreatedAt {
    final date = createdDateTime;
    if (date == null) return createdAt ?? 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get formattedUpdatedAt {
    final date = updatedDateTime;
    if (date == null) return updatedAt ?? 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'closed':
        return 'Closed';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isClosed => status.toLowerCase() == 'closed';
  bool get isCompleted => status.toLowerCase() == 'completed';

  // Helper getters for created_by field
  int? get createdById {
    if (createdBy is int) return createdBy as int;
    if (createdBy is User) return (createdBy as User).id;
    return null;
  }

  User? get createdByUser {
    if (createdBy is User) return createdBy as User;
    return null;
  }
}

class Course {
  final int? id;
  final int? trainingCenterId;
  final String title;
  final String? description;
  final int? durationDays;
  final String? createdAt;
  final String? updatedAt;

  Course({
    this.id,
    this.trainingCenterId,
    required this.title,
    this.description,
    this.durationDays,
    this.createdAt,
    this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      trainingCenterId: json['training_center_id'],
      title: json['title'],
      description: json['description'],
      durationDays: json['duration_days'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_center_id': trainingCenterId,
      'title': title,
      'description': description,
      'duration_days': durationDays,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TrainingCenter {
  final int? id;
  final String name;
  final int? specializationId;
  final String? address;
  final String? phone;
  final int? approved;
  final String? createdAt;
  final String? updatedAt;

  TrainingCenter({
    this.id,
    required this.name,
    this.specializationId,
    this.address,
    this.phone,
    this.approved,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingCenter.fromJson(Map<String, dynamic> json) {
    return TrainingCenter(
      id: json['id'],
      name: json['name'],
      specializationId: json['specialization_id'],
      address: json['address'],
      phone: json['phone'],
      approved: json['approved'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization_id': specializationId,
      'address': address,
      'phone': phone,
      'approved': approved,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Specialization {
  final int? id;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  Specialization({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class User {
  final int? id;
  final String name;
  final String? email;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    required this.name,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

