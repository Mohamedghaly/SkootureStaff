import 'package:eschool_saas_staff/data/models/driverDashboardResponse.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/material.dart';

class DriverRepository {
  Future<DriverDashboardData> getDriverDashboard() async {
    try {
      final result = await Api.get(
        url: Api.getDriverDashboard,
        useAuthToken: true,
      );

      return DriverDashboardData.fromJson(Map.from(result['data'] ?? {}));
    } catch (e, st) {
      debugPrint("this is the error: $e");
      debugPrint("this is the stack trace: $st");
      throw ApiException(e.toString());
    }
  }
}
