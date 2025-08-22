

class PayRoll {
  final int? id;
  final int? staffId;
  final double? basicSalary;
  final double? paidLeaves;
  final int? month;
  final int? year;
  final String? title;
  final double? amount;
  final String? date;
  final double? takenLeaves;

  PayRoll(
      {this.id,
      this.staffId,
      this.basicSalary,
      this.paidLeaves,
      this.month,
      this.year,
      this.title,
      this.amount,
      this.date,
      this.takenLeaves});

  PayRoll copyWith({
    int? id,
    int? staffId,
    double? basicSalary,
    double? paidLeaves,
    int? month,
    int? year,
    String? title,
    double? amount,
    String? date,
    double? takenLeaves,
  }) {
    return PayRoll(
      takenLeaves: takenLeaves ?? this.takenLeaves,
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      basicSalary: basicSalary ?? this.basicSalary,
      paidLeaves: paidLeaves ?? this.paidLeaves,
      month: month ?? this.month,
      year: year ?? this.year,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  PayRoll.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        takenLeaves = double.parse((json['taken_leaves'] ?? 0).toString()),
        staffId = json['staff_id'] as int?,
        basicSalary = double.parse((json['basic_salary'] ?? 0).toString()),
        paidLeaves = double.parse((json['paid_leaves'] ?? 0).toString()),
        month = json['month'] as int?,
        year = json['year'] as int?,
        title = json['title'] as String?,
        amount = double.parse((json['amount'] ?? 0).toString()),
        date = json['date'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'taken_leaves': takenLeaves,
        'staff_id': staffId,
        'basic_salary': basicSalary,
        'paid_leaves': paidLeaves,
        'month': month,
        'year': year,
        'title': title,
        'amount': amount,
        'date': date,
      };
}
