/// Model representing a certificate assignment from the API.
class CertificateAssignment {
  final int id;
  final int certificateTemplateId;
  final int userId;
  final String userType;
  final int? classSectionId;
  final int? sessionYearId;
  final int? examId;
  final String rollNo;
  final String issuedAt;
  final String createdAt;
  final CertificateUser? user;
  final CertificateTemplate? certificateTemplate;

  CertificateAssignment({
    required this.id,
    required this.certificateTemplateId,
    required this.userId,
    required this.userType,
    this.classSectionId,
    this.sessionYearId,
    this.examId,
    required this.rollNo,
    required this.issuedAt,
    required this.createdAt,
    this.user,
    this.certificateTemplate,
  });

  factory CertificateAssignment.fromJson(Map<String, dynamic> json) {
    return CertificateAssignment(
      id: json['id'] ?? 0,
      certificateTemplateId: json['certificate_template_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userType: (json['user_type'] ?? '').toString(),
      classSectionId: json['class_section_id'] as int?,
      sessionYearId: json['session_year_id'] as int?,
      examId: json['exam_id'] as int?,
      rollNo: (json['roll_no'] ?? '').toString(),
      issuedAt: (json['issued_at'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      user: json['user'] != null
          ? CertificateUser.fromJson(
              Map<String, dynamic>.from(json['user']),
            )
          : null,
      certificateTemplate: json['certificate_template'] != null
          ? CertificateTemplate.fromJson(
              Map<String, dynamic>.from(json['certificate_template']),
            )
          : null,
    );
  }
}

/// Nested user model within a certificate assignment.
class CertificateUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String image;
  final String fullName;

  CertificateUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.image,
    required this.fullName,
  });

  factory CertificateUser.fromJson(Map<String, dynamic> json) {
    return CertificateUser(
      id: json['id'] ?? 0,
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      mobile: (json['mobile'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
    );
  }
}

/// Nested certificate template model within a certificate assignment.
class CertificateTemplate {
  final int id;
  final String name;
  final String type;

  CertificateTemplate({
    required this.id,
    required this.name,
    required this.type,
  });

  factory CertificateTemplate.fromJson(Map<String, dynamic> json) {
    return CertificateTemplate(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
    );
  }
}
