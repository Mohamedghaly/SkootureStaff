class PaidFeeDetails {
  final int? id;
  final int? feesId;
  final int? studentId;
  final int? isFullyPaid;
  final int? isUsedInstallment;
  final double? amount;
  final String? date;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  PaidFeeDetails({
    this.id,
    this.feesId,
    this.studentId,
    this.isFullyPaid,
    this.isUsedInstallment,
    this.amount,
    this.date,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  PaidFeeDetails copyWith({
    int? id,
    int? feesId,
    int? studentId,
    int? isFullyPaid,
    int? isUsedInstallment,
    double? amount,
    String? date,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return PaidFeeDetails(
      id: id ?? this.id,
      feesId: feesId ?? this.feesId,
      studentId: studentId ?? this.studentId,
      isFullyPaid: isFullyPaid ?? this.isFullyPaid,
      isUsedInstallment: isUsedInstallment ?? this.isUsedInstallment,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  PaidFeeDetails.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        feesId = json['fees_id'] as int?,
        studentId = json['student_id'] as int?,
        isFullyPaid = json['is_fully_paid'] as int?,
        isUsedInstallment = json['is_used_installment'] as int?,
        amount = double.parse((json['amount'] ?? 0).toString()),
        date = json['date'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        deletedAt = json['deleted_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fees_id': feesId,
        'student_id': studentId,
        'is_fully_paid': isFullyPaid,
        'is_used_installment': isUsedInstallment,
        'amount': amount,
        'date': date,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt
      };
}
