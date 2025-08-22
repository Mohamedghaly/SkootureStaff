import 'package:eschool_saas_staff/data/models/additionalUserDetails.dart';
import 'package:eschool_saas_staff/data/models/role.dart';
import 'package:eschool_saas_staff/data/models/school.dart';
import 'package:eschool_saas_staff/utils/constants.dart';

class UserDetails {
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
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? fullName;
  final School? school;
  final AdditionalUserDetails? teacher;
  final AdditionalUserDetails? staff;
  final List<Role>? roles;

  UserDetails(
      {this.id,
      this.roles,
      this.firstName,
      this.lastName,
      this.mobile,
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
      this.emailVerifiedAt,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.fullName,
      this.school,
      this.staff,
      this.teacher});

  UserDetails copyWith({
    int? id,
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
    String? emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    String? fullName,
    School? school,
    AdditionalUserDetails? staff,
    AdditionalUserDetails? teacher,
    List<Role>? roles,
  }) {
    return UserDetails(
      id: id ?? this.id,
      roles: roles ?? this.roles,
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
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      fullName: fullName ?? this.fullName,
      school: school ?? this.school,
      staff: staff ?? this.staff,
      teacher: teacher ?? this.teacher,
    );
  }

  UserDetails.fromJson(Map<String, dynamic> json)
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
        emailVerifiedAt = json['email_verified_at'] as String?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        deletedAt = json['deleted_at'] as String?,
        roles = ((json['roles'] ?? []) as List)
            .map((role) => Role.fromJson(Map.from(role ?? {})))
            .toList(),
        school = School.fromJson(Map.from(json['school'] ?? {})),
        teacher =
            AdditionalUserDetails.fromJson(Map.from(json['teacher'] ?? {})),
        staff = AdditionalUserDetails.fromJson(Map.from(json['staff'] ?? {})),
        fullName = json['full_name'] as String?;

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
        'email_verified_at': emailVerifiedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'full_name': fullName,
        'school': school?.toJson(),
        'teacher': teacher?.toJson(),
        'staff': staff?.toJson(),
        'roles': roles?.map((e) => e.toJson()).toList()
      };

  bool isActive() {
    return (status == 1);
  }

  String getGender() {
    if (gender == "male") {
      return "Male";
    }

    if (gender == "female") {
      return "Female";
    }
    return gender ?? "-";
  }

  String getRoles() {
    return (roles ?? []).map((item) => item.name).toList().join(",");
  }

  bool isSchoolAdmin() {
    return (roles ?? [])
        .map((item) => item.name)
        .toList()
        .contains(schoolAdminRoleKey);
  }
}
