import 'package:eschool_saas_staff/data/models/role.dart';

class LeaveDetails {
  final int? id;
  final int? leaveId;
  final String? date;
  final String? type;
  final int? schoolId;
  final String? leaveDate;
  final Leave? leave;

  LeaveDetails({
    this.id,
    this.leaveId,
    this.date,
    this.type,
    this.schoolId,
    this.leaveDate,
    this.leave,
  });

  LeaveDetails copyWith({
    int? id,
    int? leaveId,
    String? date,
    String? type,
    int? schoolId,
    String? leaveDate,
    Leave? leave,
  }) {
    return LeaveDetails(
      id: id ?? this.id,
      leaveId: leaveId ?? this.leaveId,
      date: date ?? this.date,
      type: type ?? this.type,
      schoolId: schoolId ?? this.schoolId,
      leaveDate: leaveDate ?? this.leaveDate,
      leave: leave ?? this.leave,
    );
  }

  LeaveDetails.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        leaveId = json['leave_id'] as int?,
        date = json['date'] as String?,
        type = json['type'] as String?,
        schoolId = json['school_id'] as int?,
        leaveDate = json['leave_date'] as String?,
        leave = (json['leave'] as Map<String, dynamic>?) != null
            ? Leave.fromJson(json['leave'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'leave_id': leaveId,
        'date': date,
        'type': type,
        'school_id': schoolId,
        'leave_date': leaveDate,
        'leave': leave?.toJson()
      };
}

class Leave {
  final int? id;
  final int? userId;
  final User? user;

  Leave({
    this.id,
    this.userId,
    this.user,
  });

  Leave copyWith({
    int? id,
    int? userId,
    User? user,
  }) {
    return Leave(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
    );
  }

  Leave.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        userId = json['user_id'] as int?,
        user = (json['user'] as Map<String, dynamic>?) != null
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() =>
      {'id': id, 'user_id': userId, 'user': user?.toJson()};
}

class User {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? image;
  final List<Role>? roles;

  User(
      {this.id,
      this.firstName,
      this.lastName,
      this.fullName,
      this.image,
      this.roles});

  User copyWith(
      {int? id,
      String? firstName,
      String? lastName,
      String? fullName,
      String? image}) {
    return User(
      image: image ?? this.image,
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
    );
  }

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        firstName = json['first_name'] as String?,
        lastName = json['last_name'] as String?,
        image = json['image'] as String?,
        roles = ((json['roles'] ?? []) as List)
            .map((role) => Role.fromJson(Map.from(role ?? {})))
            .toList(),
        fullName = json['full_name'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'full_name': fullName,
        'image': image
      };
}
