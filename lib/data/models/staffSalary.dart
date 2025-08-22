import 'package:eschool_saas_staff/data/models/payRollSetting.dart';

class StaffSalary {
  final int? id;
  final int? staffId;
  final int? payrollSettingId;
  final double? amount;
  final double? percentage;
  final String? createdAt;
  final String? updatedAt;
  final PayRollSetting? payRollSetting;

  StaffSalary({
    this.id,
    this.staffId,
    this.payrollSettingId,
    this.amount,
    this.percentage,
    this.createdAt,
    this.updatedAt,
    this.payRollSetting,
  });



  StaffSalary copyWith({
    int? id,
    int? staffId,
    int? payrollSettingId,
    double? amount,
    double? percentage, // Ensured it remains double
    String? createdAt,
    String? updatedAt,
    PayRollSetting? payRollSetting,
  }) {
    return StaffSalary(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      payrollSettingId: payrollSettingId ?? this.payrollSettingId,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payRollSetting: payRollSetting ?? this.payRollSetting,
    );
  }

  StaffSalary.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        staffId = json['staff_id'] as int?,
        payrollSettingId = json['payroll_setting_id'] as int?,
        amount = double.parse((json['amount'] ?? 0).toString()),
        percentage = double.parse((json['percentage'] ?? 0).toString()),
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        payRollSetting =
            PayRollSetting.fromJson(Map.from(json['payroll_setting'] ?? {}));

  Map<String, dynamic> toJson() => {
        'id': id,
        'staff_id': staffId,
        'payroll_setting_id': payrollSettingId,
        'amount': amount,
        'percentage': percentage,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'payroll_setting': payRollSetting?.toJson(),
      };

  bool allowanceOrDeductionInPercentage() {
    return (percentage ?? 0.0) != 0.0;
  }
}
