import 'package:eschool_saas_staff/data/models/studyMaterial.dart';

class LeaveRequest {
  final int? id;
  final int? userId;
  final String? reason;
  final String? fromDate;
  final String? toDate;
  final int? status;
  final int? schoolId;
  final int? leaveMasterId;
  final String? createdAt;
  final String? updatedAt;
  final User? user;
  final List<LeaveDetail>? leaveDetail;
  final int? fullLeave;
  final int? halfLeave;
  final double? days;
  final List<StudyMaterial>? attachments;

  LeaveRequest(
      {this.id,
      this.userId,
      this.reason,
      this.fromDate,
      this.attachments,
      this.toDate,
      this.status,
      this.schoolId,
      this.leaveMasterId,
      this.createdAt,
      this.updatedAt,
      this.user,
      this.leaveDetail,
      this.days,
      this.fullLeave,
      this.halfLeave});

  LeaveRequest copyWith(
      {int? id,
      int? userId,
      String? reason,
      String? fromDate,
      String? toDate,
      int? status,
      int? schoolId,
      int? leaveMasterId,
      String? createdAt,
      String? updatedAt,
      User? user,
      List<LeaveDetail>? leaveDetail,
      int? fullLeave,
      int? halfLeave,
      List<StudyMaterial>? attachments,
      double? days}) {
    return LeaveRequest(
      id: id ?? this.id,
      attachments: attachments ?? this.attachments,
      days: days ?? this.days,
      fullLeave: fullLeave ?? this.fullLeave,
      halfLeave: halfLeave ?? this.halfLeave,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      status: status ?? this.status,
      schoolId: schoolId ?? this.schoolId,
      leaveMasterId: leaveMasterId ?? this.leaveMasterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      leaveDetail: leaveDetail ?? this.leaveDetail,
    );
  }

  LeaveRequest.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        attachments = (json['file'] as List?)
            ?.map((e) => StudyMaterial.fromJson(Map.from(e)))
            .toList(),
        userId = json['user_id'] as int?,
        reason = json['reason'] as String?,
        fromDate = json['from_date'] as String?,
        toDate = json['to_date'] as String?,
        status = json['status'] as int?,
        schoolId = json['school_id'] as int?,
        leaveMasterId = json['leave_master_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        user = (json['user'] as Map<String, dynamic>?) != null
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        days = double.parse((json['days'] ?? 0).toString()),
        fullLeave = json['full_leave'] as int?,
        halfLeave = json['half_leave'] as int?,
        leaveDetail = (json['leave_detail'] as List?)
            ?.map(
                (dynamic e) => LeaveDetail.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'reason': reason,
        'from_date': fromDate,
        'to_date': toDate,
        'status': status,
        'school_id': schoolId,
        'leave_master_id': leaveMasterId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'days': days,
        'full_leave': fullLeave,
        'half_leave': halfLeave,
        'user': user?.toJson(),
        'leave_detail': leaveDetail?.map((e) => e.toJson()).toList()
      };
}

class User {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String? email;
  final String? mobile;
  final String? fullName;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.image,
    this.email,
    this.mobile,
    this.fullName,
  });

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? image,
    String? email,
    String? mobile,
    String? fullName,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      image: image ?? this.image,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      fullName: fullName ?? this.fullName,
    );
  }

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        firstName = json['first_name'] as String?,
        lastName = json['last_name'] as String?,
        image = json['image'] as String?,
        email = json['email'] as String?,
        mobile = json['mobile'] as String?,
        fullName = json['full_name'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'image': image,
        'email': email,
        'mobile': mobile,
        'full_name': fullName
      };
}

class LeaveDetail {
  final int? id;
  final int? leaveId;
  final String? date;
  final String? type;
  final int? schoolId;

  LeaveDetail({
    this.id,
    this.leaveId,
    this.date,
    this.type,
    this.schoolId,
  });

  LeaveDetail copyWith({
    int? id,
    int? leaveId,
    String? date,
    String? type,
    int? schoolId,
  }) {
    return LeaveDetail(
      id: id ?? this.id,
      leaveId: leaveId ?? this.leaveId,
      date: date ?? this.date,
      type: type ?? this.type,
      schoolId: schoolId ?? this.schoolId,
    );
  }

  LeaveDetail.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        leaveId = json['leave_id'] as int?,
        date = json['date'] as String?,
        type = json['type'] as String?,
        schoolId = json['school_id'] as int?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'leave_id': leaveId,
        'date': date,
        'type': type,
        'school_id': schoolId
      };

  bool isFullLeave() {
    return type == "Full";
  }
}
