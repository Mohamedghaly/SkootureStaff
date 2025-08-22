import 'package:eschool_saas_staff/data/models/leaveRequest.dart';
import 'package:eschool_saas_staff/data/models/payRoll.dart';
import 'package:eschool_saas_staff/data/models/staffSalary.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';

class StaffPayRoll {
  final int? id;
  final int? userId;
  final String? qualification;
  final double? salary;
  final UserDetails? userDetails;
  final List<LeaveRequest>? leaveRequests;
  final List<PayRoll>? payRolls;
  final List<StaffSalary>? staffSalaries;

  StaffPayRoll(
      {this.id,
      this.userId,
      this.qualification,
      this.salary,
      this.userDetails,
      this.leaveRequests,
      this.payRolls,
      this.staffSalaries});

  StaffPayRoll copyWith(
      {int? id,
      int? userId,
      String? qualification,
      double? salary,
      UserDetails? userDetails,
      List<LeaveRequest>? leaveRequests,
      List<PayRoll>? payRolls,
      List<StaffSalary>? staffSalaries}) {
    return StaffPayRoll(
      staffSalaries: staffSalaries ?? this.staffSalaries,
      payRolls: payRolls ?? this.payRolls,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      userDetails: userDetails ?? this.userDetails,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      qualification: qualification ?? this.qualification,
      salary: salary ?? this.salary,
    );
  }

  StaffPayRoll.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        payRolls = ((json['expense'] ?? []) as List)
            .map((payRoll) => PayRoll.fromJson(Map.from(payRoll ?? {})))
            .toList(),
        leaveRequests = ((json['leave'] ?? []) as List)
            .map((leaveRequest) =>
                LeaveRequest.fromJson(Map.from(leaveRequest ?? {})))
            .toList(),
        userId = json['user_id'] as int?,
        qualification = json['qualification'] as String?,
        staffSalaries = ((json['staff_salary'] ?? []) as List)
            .map((salary) => StaffSalary.fromJson(Map.from(salary ?? {})))
            .toList(),
        userDetails = UserDetails.fromJson(Map.from(json['user'] ?? {})),
        salary = double.parse((json['salary'] ?? 0).toString());

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'qualification': qualification,
        'salary': salary,
        'user': userDetails?.toJson(),
        'leave': leaveRequests?.map((e) => e.toJson()).toList(),
        'expense': payRolls?.map((e) => e.toJson()).toList(),
        'staff_salary': staffSalaries?.map((value) => value.toJson()).toList(),
      };

  bool receivedPayroll() {
    return (payRolls ?? []).isNotEmpty;
  }

  double perDaySalaryAmount() {
    return (salary ?? 0) / 30;
  }

  double getTotalDeductionsAmount() {
    double deductionAmount = 0.0;

    for (var staffSalary in getDeductions()) {
      if (staffSalary.allowanceOrDeductionInPercentage()) {
        deductionAmount = deductionAmount +
            ((salary ?? 0.0) * ((staffSalary.percentage ?? 0) * 0.01));
      } else {
        deductionAmount = deductionAmount + (staffSalary.amount ?? 0);
      }
    }
    return deductionAmount;
  }

  double getTotalAllowancesAmount() {
    double allowanceAmount = 0.0;

    for (var staffSalary in getAllowances()) {
      if (staffSalary.allowanceOrDeductionInPercentage()) {
        allowanceAmount = allowanceAmount +
            ((salary ?? 0.0) * ((staffSalary.percentage ?? 0) * 0.01));
      } else {
        allowanceAmount = allowanceAmount + (staffSalary.amount ?? 0);
      }
    }
    return allowanceAmount;
  }

  double getPossibleSalaryDeductionAmount({required double allowedLeaves}) {
    double deductionAmount = 0.0;

    ///[If user has taken more than allowed leaves then deduct the amount]
    if (totalTakenLeaves() > allowedLeaves) {
      final minimumAmountToDeduct = (perDaySalaryAmount());

      final leaveDayDifference = totalTakenLeaves() - allowedLeaves;

      deductionAmount = (minimumAmountToDeduct * leaveDayDifference);
    }

    return deductionAmount;
  }

  double totalTakenLeaves() {
    double takenLeaves = 0;

    for (var leaveRequest in leaveRequests ?? List<LeaveRequest>.from([])) {
      takenLeaves = takenLeaves +
          (leaveRequest.fullLeave ?? 0) +
          ((leaveRequest.halfLeave ?? 0) / 2);
    }
    return takenLeaves;
  }

  List<StaffSalary> getAllowances() {
    return (staffSalaries ?? [])
        .where((staffSalary) =>
            (staffSalary.payRollSetting?.isAllowance() ?? false))
        .toList();
  }

  List<StaffSalary> getDeductions() {
    return (staffSalaries ?? [])
        .where((staffSalary) =>
            (staffSalary.payRollSetting?.isDeduction() ?? false))
        .toList();
  }

  double getNetSalaryAmount({required double allowedMonthlyLeaves}) {
    if (receivedPayroll()) {
      return (payRolls?.first.amount ?? 0);
    } else {
      double netSalaryAmount = (salary ?? 0) -
          getPossibleSalaryDeductionAmount(
              allowedLeaves: allowedMonthlyLeaves) -
          getTotalDeductionsAmount() +
          getTotalAllowancesAmount();

      return netSalaryAmount;
    }
  }
}
