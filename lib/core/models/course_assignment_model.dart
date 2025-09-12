class CourseAssignment {
  final int id;
  final String code;
  final String title;
  final String description;
  final Specialization specialization;
  final List<Assignment> assignments;

  CourseAssignment({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.specialization,
    required this.assignments,
  });

  factory CourseAssignment.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing CourseAssignment: ${json['title']}');
    print('🔍 Assignments field type: ${json['assignments'].runtimeType}');
    print('🔍 Assignments field value: ${json['assignments']}');
    
    // Handle assignments as either a List or a single Map
    List<Assignment> assignmentsList = [];
    if (json['assignments'] != null) {
      if (json['assignments'] is List) {
        print('🔍 Processing assignments as List');
        // If it's a list, process each item
        assignmentsList = (json['assignments'] as List<dynamic>)
            .map((assignment) => Assignment.fromJson(assignment))
            .toList();
      } else if (json['assignments'] is Map) {
        print('🔍 Processing assignments as single Map');
        // If it's a single object, wrap it in a list
        assignmentsList = [Assignment.fromJson(json['assignments'] as Map<String, dynamic>)];
      } else {
        print('🔍 Assignments field is neither List nor Map: ${json['assignments'].runtimeType}');
      }
    } else {
      print('🔍 Assignments field is null');
    }
    
    print('🔍 Final assignments list length: ${assignmentsList.length}');

    return CourseAssignment(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      specialization: Specialization.fromJson(json['specialization'] ?? {}),
      assignments: assignmentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'specialization': specialization.toJson(),
      'assignments': assignments.map((assignment) => assignment.toJson()).toList(),
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
      id: json['id'] ?? 0,
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

class Assignment {
  final int id;
  final TrainingCenterBranch trainingCenterBranch;
  final String startDate;
  final String endDate;
  final int seats;
  final int availableSeats;
  final bool isActive;
  final bool isFuture;
  final bool isPast;

  Assignment({
    required this.id,
    required this.trainingCenterBranch,
    required this.startDate,
    required this.endDate,
    required this.seats,
    required this.availableSeats,
    required this.isActive,
    required this.isFuture,
    required this.isPast,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      trainingCenterBranch: TrainingCenterBranch.fromJson(json['training_center_branch'] ?? {}),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      seats: json['seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      isActive: json['is_active'] ?? false,
      isFuture: json['is_future'] ?? false,
      isPast: json['is_past'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_center_branch': trainingCenterBranch.toJson(),
      'start_date': startDate,
      'end_date': endDate,
      'seats': seats,
      'available_seats': availableSeats,
      'is_active': isActive,
      'is_future': isFuture,
      'is_past': isPast,
    };
  }
}

class TrainingCenterBranch {
  final int id;
  final String name;
  final TrainingCenter trainingCenter;

  TrainingCenterBranch({
    required this.id,
    required this.name,
    required this.trainingCenter,
  });

  factory TrainingCenterBranch.fromJson(Map<String, dynamic> json) {
    return TrainingCenterBranch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      trainingCenter: TrainingCenter.fromJson(json['training_center'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'training_center': trainingCenter.toJson(),
    };
  }
}

class TrainingCenter {
  final int id;
  final String name;

  TrainingCenter({
    required this.id,
    required this.name,
  });

  factory TrainingCenter.fromJson(Map<String, dynamic> json) {
    return TrainingCenter(
      id: json['id'] ?? 0,
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

class CourseAssignmentListResponse {
  final bool success;
  final List<CourseAssignment> data;
  final String messageAr;
  final String messageEn;
  final int statusCode;

  CourseAssignmentListResponse({
    required this.success,
    required this.data,
    required this.messageAr,
    required this.messageEn,
    required this.statusCode,
  });

  factory CourseAssignmentListResponse.fromJson(Map<String, dynamic> json) {
    return CourseAssignmentListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((course) => CourseAssignment.fromJson(course))
          .toList() ?? [],
      messageAr: json['message_ar'] ?? '',
      messageEn: json['message_en'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((course) => course.toJson()).toList(),
      'message_ar': messageAr,
      'message_en': messageEn,
      'status_code': statusCode,
    };
  }
}

class CourseAssignmentRequest {
  final int trainingPlanId;
  final int companyId;

  CourseAssignmentRequest({
    required this.trainingPlanId,
    required this.companyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'training_plan_id': trainingPlanId,
      'company_id': companyId,
    };
  }
}
