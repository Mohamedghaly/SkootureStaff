import 'package:eschool_saas_staff/data/models/transportUserAttendance.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class TransportUserAttendanceRepository {
  /// Fetch attendance records for a user
  Future<TransportUserAttendanceData> getAttendanceList({
    required int userId,
    String? month,
    String? tripType,
  }) async {
    try {
      // Prepare request body
      final Map<String, dynamic> body = {
        'user_id': userId.toString(),
      };

      // Add optional filters
      if (month != null && month.isNotEmpty) {
        body['month'] = month;
      }

      if (tripType != null &&
          tripType.isNotEmpty &&
          tripType.toLowerCase() != 'all') {
        body['trip_type'] = tripType.toLowerCase();
      }

      debugPrint("Fetching attendance with body: $body");

      final result = await Api.post(
        url: Api.getTransportUserAttendanceList,
        useAuthToken: true,
        body: body,
      );

      debugPrint("API Response: $result");

      // Parse the response
      final response = TransportUserAttendanceResponse.fromJson(result);

      if (response.error) {
        throw ApiException(response.message);
      }

      return response.data;
    } catch (e, stackTrace) {
      debugPrint("Error fetching attendance: $e");
      debugPrint("Stack trace: $stackTrace");
      throw ApiException(e.toString());
    }
  }

  /// Get available months for filtering
  List<FilterOption> getMonthOptions() {
    final months = <FilterOption>[];

    // Add all 12 months in correct order (January to December)
    for (int i = 1; i <= 12; i++) {
      final monthValue = i.toString().padLeft(2, '0');
      final monthName = _getMonthName(i);

      months.add(FilterOption(
        label: monthName, // Only month name, no year
        value: monthValue,
      ));
    }

    return months;
  }

  /// Get current month label with year for display
  String getCurrentMonthLabelWithYear(String? monthValue) {
    if (monthValue == null) return '';

    final monthInt = int.tryParse(monthValue);
    if (monthInt == null || monthInt < 1 || monthInt > 12) return '';

    final monthName = _getMonthName(monthInt);
    final currentYear = DateTime.now().year;

    return '$monthName $currentYear';
  }

  /// Get trip type filter options
  List<FilterOption> getTripTypeOptions() {
    return [
      FilterOption(label: Utils.getTranslatedLabel(allKey), value: 'all'),
      FilterOption(label: Utils.getTranslatedLabel(pickupKey), value: 'pickup'),
      FilterOption(label: Utils.getTranslatedLabel(dropKey), value: 'drop'),
    ];
  }

  String _getMonthName(int month) {
    const monthKeys = [
      januaryKey,
      februaryKey,
      marchKey,
      aprilKey,
      mayKey,
      juneKey,
      julyKey,
      augustKey,
      septemberKey,
      octoberKey,
      novemberKey,
      decemberKey,
    ];
    return Utils.getTranslatedLabel(monthKeys[month - 1]);
  }
}
