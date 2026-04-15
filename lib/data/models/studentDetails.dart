import 'package:eschool_saas_staff/data/models/offlineExamSubjectResult.dart';
import 'package:eschool_saas_staff/data/models/paidFeeDetails.dart';
import 'package:eschool_saas_staff/data/models/student.dart';
import 'package:eschool_saas_staff/utils/constants.dart';

/// Model for form field information
class FormField {
  final int? id;
  final String? name;
  final String? type;
  final int? isRequired;
  final dynamic defaultValues; // Can be null, String, or List<String>
  final int? schoolId;
  final int? userType;
  final int? rank;
  final int? displayOnId;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  FormField({
    this.id,
    this.name,
    this.type,
    this.isRequired,
    this.defaultValues,
    this.schoolId,
    this.userType,
    this.rank,
    this.displayOnId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'] as int?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      isRequired: json['is_required'] as int?,
      defaultValues: json['default_values'], // Keep as dynamic
      schoolId: json['school_id'] as int?,
      userType: json['user_type'] as int?,
      rank: json['rank'] as int?,
      displayOnId: json['display_on_id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'is_required': isRequired,
      'default_values': defaultValues,
      'school_id': schoolId,
      'user_type': userType,
      'rank': rank,
      'display_on_id': displayOnId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  /// Get default values as a list of strings
  /// Handles both single values and arrays from the API
  List<String> getDefaultValuesAsList() {
    if (defaultValues == null) return [];
    if (defaultValues is List) {
      return (defaultValues as List).map((e) => e.toString()).toList();
    }
    return [defaultValues.toString()];
  }

  /// Get default values as a single string (for display purposes)
  String getDefaultValuesAsString() {
    if (defaultValues == null) return '';
    if (defaultValues is List) {
      return (defaultValues as List).join(', ');
    }
    return defaultValues.toString();
  }
}

/// Model for extra/custom student details
class ExtraStudentDetail {
  final int? id;
  final int? userId;
  final int? formFieldId;
  final String? data;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? fileUrl;
  final FormField? formField;

  ExtraStudentDetail({
    this.id,
    this.userId,
    this.formFieldId,
    this.data,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.fileUrl,
    this.formField,
  });

  factory ExtraStudentDetail.fromJson(Map<String, dynamic> json) {
    return ExtraStudentDetail(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      formFieldId: json['form_field_id'] as int?,
      data: json['data'] as String?,
      schoolId: json['school_id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      fileUrl: json['file_url'] as String?,
      formField: json['form_field'] != null
          ? FormField.fromJson(Map.from(json['form_field']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'form_field_id': formFieldId,
      'data': data,
      'school_id': schoolId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'file_url': fileUrl,
      'form_field': formField?.toJson(),
    };
  }

  /// Get the field name from form_field or fallback to generic label
  String getFieldName() {
    if (formField?.name != null && formField!.name!.isNotEmpty) {
      return formField!.name!;
    }
    return 'Field $formFieldId';
  }

  /// Check if this detail contains a file (has data that looks like a file path)
  bool isFileField() {
    if (data == null || data!.isEmpty) return false;
    // Check if data contains file extensions or file path patterns
    final fileExtensions = ['.jpg', '.jpeg', '.png', '.pdf', '.doc', '.docx', '.xls', '.xlsx'];
    return fileExtensions.any((ext) => data!.toLowerCase().contains(ext));
  }

  /// Get the full file URL for display/download
  /// Prioritizes file_url from API, then constructs from data path
  String? getFileUrl() {
    // Priority 1: Use file_url if provided by API (direct URL)
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      return fileUrl;
    }

    // Priority 2: Check if data looks like a file and construct URL
    if (data == null || data!.isEmpty) return null;
    if (isFileField()) {
      // Construct URL from data path
      return '$baseUrl/storage/$data';
    }

    return null;
  }
}

class StudentDetails {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? mobile;
  final String? email;
  final String? gender;
  final String? image;
  final String? dob;
  final String? currentAddress;
  final String? permanentAddress;
  final String? occupation;
  final int? status;
  final int? resetRequest;
  final String? fcmId;
  final int? schoolId;
  final String? language;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? fullName;
  final String? schoolNames;
  final Student? student;
  final List<OfflineExamSubjectResult>? offlineExamMarks;
  final List<ExamMarks>? examMarks;
  final PaidFeeDetails? paidFeeDetails;
  final List<ExtraStudentDetail>? extraStudentDetails;

  StudentDetails({
    this.id,
    this.student,
    this.firstName,
    this.lastName,
    this.mobile,
    this.paidFeeDetails,
    this.email,
    this.gender,
    this.image,
    this.dob,
    this.currentAddress,
    this.permanentAddress,
    this.occupation,
    this.status,
    this.resetRequest,
    this.fcmId,
    this.schoolId,
    this.language,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.fullName,
    this.schoolNames,
    this.offlineExamMarks,
    this.examMarks,
    this.extraStudentDetails,
  });

  StudentDetails copyWith(
      {int? id,
      String? firstName,
      String? lastName,
      String? mobile,
      String? email,
      String? gender,
      String? image,
      String? dob,
      String? currentAddress,
      String? permanentAddress,
      String? occupation,
      int? status,
      int? resetRequest,
      String? fcmId,
      int? schoolId,
      String? language,
      String? emailVerifiedAt,
      String? createdAt,
      String? updatedAt,
      String? deletedAt,
      String? fullName,
      String? schoolNames,
      Student? student}) {
    return StudentDetails(
      id: id ?? this.id,
      student: student ?? this.student,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      dob: dob ?? this.dob,
      currentAddress: currentAddress ?? this.currentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      occupation: occupation ?? this.occupation,
      status: status ?? this.status,
      resetRequest: resetRequest ?? this.resetRequest,
      fcmId: fcmId ?? this.fcmId,
      schoolId: schoolId ?? this.schoolId,
      language: language ?? this.language,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      fullName: fullName ?? this.fullName,
      schoolNames: schoolNames ?? this.schoolNames,
    );
  }

  StudentDetails.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        firstName = json['first_name'] as String?,
        lastName = json['last_name'] as String?,
        mobile = json['mobile'] as String?,
        email = json['email'] as String?,
        gender = json['gender'] as String?,
        image = json['image'] as String?,
        dob = json['dob'] as String?,
        currentAddress = json['current_address'] as String?,
        permanentAddress = json['permanent_address'] as String?,
        occupation = json['occupation'] as String?,
        status = json['status'] as int?,
        resetRequest = json['reset_request'] as int?,
        fcmId = json['fcm_id'] as String?,
        schoolId = json['school_id'] as int?,
        language = json['language'] as String?,
        emailVerifiedAt = json['email_verified_at'] as String?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        deletedAt = json['deleted_at'] as String?,
        fullName = json['full_name'] as String?,
        offlineExamMarks = ((json['exam_marks'] ?? []) as List)
            .map((offlineExamSubjectResult) =>
                OfflineExamSubjectResult.fromJson(
                    Map.from(offlineExamSubjectResult ?? {})))
            .toList(),
        student = Student.fromJson(Map.from(json['student'] ?? {})),
        schoolNames = json['school_names'] as String?,
        paidFeeDetails =
            PaidFeeDetails.fromJson(Map.from(json['fees_paid'] ?? {})),
        examMarks = ((json['marks'] ?? []) as List)
            .map<ExamMarks>((e) => ExamMarks.fromJson(Map.from(e ?? {})))
            .toList(),
        extraStudentDetails = ((json['extra_student_details'] ?? []) as List)
            .map((detail) => ExtraStudentDetail.fromJson(Map.from(detail ?? {})))
            .toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'mobile': mobile,
        'email': email,
        'gender': gender,
        'image': image,
        'dob': dob,
        'current_address': currentAddress,
        'permanent_address': permanentAddress,
        'occupation': occupation,
        'status': status,
        'reset_request': resetRequest,
        'fcm_id': fcmId,
        'school_id': schoolId,
        'language': language,
        'email_verified_at': emailVerifiedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'full_name': fullName,
        'school_names': schoolNames,
        'student': student?.toJson(),
      };

  String getGender() {
    if (gender == "male") {
      return "Male";
    }

    if (gender == "female") {
      return "Female";
    }
    return gender ?? "-";
  }

  bool isActive() {
    return (status == 1);
  }
}

//For offline exam existing marks
class ExamMarks {
  int id;
  int examTimetableId;
  int studentId;
  double
      obtainedMarks; 

  ExamMarks({
    required this.id,
    required this.examTimetableId,
    required this.studentId,
    required this.obtainedMarks,
  });

  factory ExamMarks.fromJson(Map<String, dynamic> json) {
    return ExamMarks(
      id: json['id'] ?? 0,
      examTimetableId: json['exam_timetable_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      obtainedMarks: json['obtained_marks'] is int
          ? (json['obtained_marks'] as int).toDouble()
          : json['obtained_marks']?.toDouble() ?? 0.0,
    );
  }
}
