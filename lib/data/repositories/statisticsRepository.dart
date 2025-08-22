import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/foundation.dart';

class StatisticsRepository {
  Future<
      ({
        int totalStudents,
        int totalStaffs,
        int totalTeachers,
        int totalLeaveRequests
      })> getSystemStatistics() async {
    try {
      final result = await Api.get(url: Api.getSystemStatistics);

      if (kDebugMode) {
        print(result);
      }

      return (
        totalStudents: int.parse((result['data']['students'] ?? 0).toString()),
        totalStaffs: int.parse((result['data']['staffs'] ?? 0).toString()),
        totalTeachers: int.parse((result['data']['teachers'] ?? 0).toString()),
        totalLeaveRequests:
            int.parse((result['data']['leaves'] ?? 0).toString()),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
