class TrainingPlanByCompany {
  final int id;
  final int year;
  final String title;
  final String description;
  final String status;
  final int createdBy;
  final Creator creator;
  final List<PlanCourseAssignment> planCourseAssignments;
  final String createdAt;
  final String updatedAt;

  TrainingPlanByCompany({
    required this.id,
    required this.year,
    required this.title,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.creator,
    required this.planCourseAssignments,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper function to safely convert dynamic to int
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

  factory TrainingPlanByCompany.fromJson(Map<String, dynamic> json) {
    return TrainingPlanByCompany(
      id: _toInt(json['id']),
      year: _toInt(json['year']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdBy: _toInt(json['created_by']),
      creator: Creator.fromJson(json['creator'] ?? {}),
      planCourseAssignments: (json['plan_course_assignments'] as List<dynamic>?)
          ?.map((assignment) => PlanCourseAssignment.fromJson(assignment))
          .toList() ?? [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'title': title,
      'description': description,
      'status': status,
      'created_by': createdBy,
      'creator': creator.toJson(),
      'plan_course_assignments': planCourseAssignments.map((assignment) => assignment.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Creator {
  final int id;
  final String name;
  final String email;

  Creator({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: TrainingPlanByCompany._toInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class PlanCourseAssignment {
  final int id;
  final int trainingPlanId;
  final int companyId;
  final int courseId;
  final int trainingCenterBranchId;
  final String startDate;
  final String endDate;
  final int seats;
  final Company company;
  final Course course;
  final TrainingCenterBranch trainingCenterBranch;

  PlanCourseAssignment({
    required this.id,
    required this.trainingPlanId,
    required this.companyId,
    required this.courseId,
    required this.trainingCenterBranchId,
    required this.startDate,
    required this.endDate,
    required this.seats,
    required this.company,
    required this.course,
    required this.trainingCenterBranch,
  });

  factory PlanCourseAssignment.fromJson(Map<String, dynamic> json) {
    return PlanCourseAssignment(
      id: TrainingPlanByCompany._toInt(json['id']),
      trainingPlanId: TrainingPlanByCompany._toInt(json['training_plan_id']),
      companyId: TrainingPlanByCompany._toInt(json['company_id']),
      courseId: TrainingPlanByCompany._toInt(json['course_id']),
      trainingCenterBranchId: TrainingPlanByCompany._toInt(json['training_center_branch_id']),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      seats: TrainingPlanByCompany._toInt(json['seats']),
      company: Company.fromJson(json['company'] ?? {}),
      course: Course.fromJson(json['course'] ?? {}),
      trainingCenterBranch: TrainingCenterBranch.fromJson(json['training_center_branch'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_plan_id': trainingPlanId,
      'company_id': companyId,
      'course_id': courseId,
      'training_center_branch_id': trainingCenterBranchId,
      'start_date': startDate,
      'end_date': endDate,
      'seats': seats,
      'company': company.toJson(),
      'course': course.toJson(),
      'training_center_branch': trainingCenterBranch.toJson(),
    };
  }
}

class Company {
  final int id;
  final String name;
  final String email;

  Company({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: TrainingPlanByCompany._toInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class Course {
  final int id;
  final String code;
  final String title;
  final String description;
  final Specialization specialization;

  Course({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.specialization,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: TrainingPlanByCompany._toInt(json['id']),
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      specialization: Specialization.fromJson(json['specialization'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'specialization': specialization.toJson(),
    };
  }
}

class Specialization {
  final int id;
  final String name;

  Specialization({
    required this.id,
    required this.name,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: TrainingPlanByCompany._toInt(json['id']),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TrainingCenterBranch {
  final int id;
  final String name;
  final String address;

  TrainingCenterBranch({
    required this.id,
    required this.name,
    required this.address,
  });

  factory TrainingCenterBranch.fromJson(Map<String, dynamic> json) {
    return TrainingCenterBranch(
      id: TrainingPlanByCompany._toInt(json['id']),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }
}

class TrainingPlanByCompanyListResponse {
  final bool success;
  final List<TrainingPlanByCompany> data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  TrainingPlanByCompanyListResponse({
    required this.success,
    required this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory TrainingPlanByCompanyListResponse.fromJson(Map<String, dynamic> json) {
    return TrainingPlanByCompanyListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((plan) => TrainingPlanByCompany.fromJson(plan))
          .toList() ?? [],
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: TrainingPlanByCompany._toInt(json['status_code']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((plan) => plan.toJson()).toList(),
      'message_ar': messageAr,
      'message_en': messageEn,
      'status_code': statusCode,
    };
  }
}

class TrainingPlanByCompanyRequest {
  final int companyId;

  TrainingPlanByCompanyRequest({
    required this.companyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
    };
  }
}
