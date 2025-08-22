import 'package:eschool_saas_staff/data/models/staffSalary.dart';

class AdditionalUserDetails {
  final int? id;
  final int? userId;
  final String? qualification;
  final double? salary;
  final List<StaffSalary>? staffSalaries;

  AdditionalUserDetails({
    this.id,
    this.userId,
    this.qualification,
    this.salary,
    this.staffSalaries,
  });

  AdditionalUserDetails copyWith({
    int? id,
    int? userId,
    String? qualification,
    double? salary,
    List<StaffSalary>? staffSalaries,
  }) {
    return AdditionalUserDetails(
      staffSalaries: staffSalaries ?? this.staffSalaries,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      qualification: qualification ?? this.qualification,
      salary: salary ?? this.salary,
    );
  }

  AdditionalUserDetails.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        userId = json['user_id'] as int?,
        qualification = json['qualification'] as String?,
        staffSalaries = ((json['staff_salary'] ?? []) as List)
            .map((staffSalary) =>
                StaffSalary.fromJson(Map.from(staffSalary ?? {})))
            .toList(),
        salary = double.parse((json['salary'] ?? 0).toString());

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'qualification': qualification,
        'salary': salary,
        'staff_salary':
            staffSalaries?.map((staffSalary) => staffSalary.toJson()).toList()
      };
}
