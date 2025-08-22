class PayRollSetting {
  final int? id;
  final String? name;
  final double? amount;
  final double? percentage;

  ///[Type will have value allowance or deduction]
  final String? type;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;

  PayRollSetting({
    this.id,
    this.name,
    this.amount,
    this.percentage,
    this.type,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
  });

  PayRollSetting copyWith({
    int? id,
    String? name,
    double? amount,
    double? percentage,
    String? type,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
  }) {
    return PayRollSetting(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      type: type ?? this.type,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  PayRollSetting.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        amount = double.parse((json['amount'] ?? 0).toString()),
        percentage = double.parse((json['percentage'] ?? 0).toString()),
        type = json['type'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'percentage': percentage,
        'type': type,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt
      };

  bool isAllowance() {
    return type == "allowance";
  }

  bool isDeduction() {
    return type == "deduction";
  }
}
