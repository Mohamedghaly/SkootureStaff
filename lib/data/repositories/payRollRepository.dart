import 'package:eschool_saas_staff/data/models/payRoll.dart';
import 'package:eschool_saas_staff/data/models/staffPayRoll.dart';
import 'package:eschool_saas_staff/data/models/staffSalary.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/foundation.dart';

class PayRollRepository {
  Future<List<PayRoll>> getMyPayRoll({required int sessionYearId}) async {
    try {
      final result = await Api.get(
          url: Api.getMyPayRolls,
          queryParameters: {"session_year_id": sessionYearId});

      return ((result['data'] ?? []) as List)
          .map((payRoll) => PayRoll.fromJson(Map.from(payRoll ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> downloadPayRollSlip({required int payRollId}) async {
    try {
      final result = await Api.get(
          url: Api.downloadPayRollSlip,
          queryParameters: {"slip_id": payRollId});

      return (result['pdf'] ?? "").toString();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<String>> getPayRollYears() async {
    try {
      final result = await Api.get(url: Api.getPayRollYears);

      return ((result['data'] ?? []) as List).map((e) => e.toString()).toList();
    } catch (e) {
   
      throw ApiException(e.toString());
    }
  }

  Future<({double allowedLeaves, List<StaffPayRoll> staffsPayRoll})>
      getStaffsPayroll({required int year, required int month}) async {
    try {
      final result = await Api.get(
          url: Api.getStaffsPayroll,
          queryParameters: {"month": month, "year": year});

      return (
        allowedLeaves: result['leave_master'] != null
            ? double.parse((result['leave_master']['leaves'] ?? 0).toString())
            : 0.0,
        staffsPayRoll: ((result['data'] ?? []) as List)
            .map((staffPayRoll) =>
                StaffPayRoll.fromJson(Map.from(staffPayRoll ?? {})))
            .toList(),
      );
    } catch (e, stc) {
      if (kDebugMode) {
        print(stc);
      }
      throw ApiException(e.toString());
    }
  }

  Future<void> submitStaffsPayRoll(
      {required int month,
      required int year,
      required double allowedLeaves,
      required List<Map<String, dynamic>> staffPayRolls}) async {
    try {
      await Api.post(body: {
        "month": month,
        "year": year,
        "allowed_leaves": allowedLeaves,
        "payroll": staffPayRolls
      }, url: Api.submitStaffsPayroll);
    } catch (e, st) {
      print("This is the Error: $e");
      print("This is the Stack Trace: $st");
      throw ApiException(e.toString());
    }
  }

  Future<({List<StaffSalary> allowances, List<StaffSalary> deductions})>
      getAllowancesAndDeductions() async {
    try {
      final result = await Api.get(url: Api.getAllowancesAndDeductions);
      final UserDetails userDetails =
          UserDetails.fromJson(Map.from(result['data'] ?? {}));
      final isTeacher = userDetails.teacher?.id != null;

      return (
        allowances: isTeacher
            ? (userDetails.teacher?.staffSalaries ?? []).where((staffSalary) {
                return (staffSalary.payRollSetting?.isAllowance() ?? false);
              }).toList()
            : (userDetails.staff?.staffSalaries ?? [])
                .where((staffSalary) =>
                    (staffSalary.payRollSetting?.isAllowance() ?? false))
                .toList(),
        deductions: isTeacher
            ? (userDetails.teacher?.staffSalaries ?? [])
                .where((staffSalary) =>
                    (staffSalary.payRollSetting?.isDeduction() ?? false))
                .toList()
            : (userDetails.staff?.staffSalaries ?? [])
                .where((staffSalary) =>
                    (staffSalary.payRollSetting?.isDeduction() ?? false))
                .toList(),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
