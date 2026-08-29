import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/material.dart';

class StaffAttendanceRepository {
  /// Get teachers list for a specific class section
  /// API: GET /api/staff/teachers?class_section_id=X
  Future<List<StaffMember>> getTeachersForClass({
    required int classSectionId,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getTeachers,
        queryParameters: {
          'class_section_id': classSectionId,
        },
      );

      final data = result['data'];
      if (data is List) {
        return data
            .map((teacher) => StaffMember.fromJson(Map.from(teacher ?? {})))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Get staff attendance for a specific date
  /// API: GET /api/staff/staff-attendance?mode=daily&date=YYYY-MM-DD&class_section_id=X&search=keyword
  /// Note: This API returns data directly at root level without standard "error" field wrapper
  Future<StaffAttendanceResponse> getStaffAttendance({
    required String date,
    int? classSectionId,
    String? search,
  }) async {
    try {
      // Build query parameters, only include class_section_id if it's not null
      final Map<String, dynamic> queryParams = {
        'date': date,
      };

      // Only add class_section_id if it's provided
      if (classSectionId != null) {
        queryParams['class_section_id'] = classSectionId;
      }

      // Only add search if it's provided and not empty
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      // Use skipErrorCheck=true because this API doesn't have "error" field in response
      final result = await Api.get(
        url: Api.getStaffAttendance,
        queryParameters: queryParams,
        skipErrorCheck: true, // This API has non-standard response format
      );

      // The API can return two different formats:
      // 1. Holiday format: { "date": "...", "status": "holiday", "code": 3, "message": "..." }
      // 2. Normal format: { "date": "...", "total": ..., "rows": [...] }

      // Check if response is a holiday status
      if (result.containsKey('status') && result['status'] == 'holiday') {
        return StaffAttendanceResponse.fromJson(Map.from(result));
      }

      // Check if 'rows' field exists at root level (normal response)
      if (result.containsKey('rows')) {
        return StaffAttendanceResponse.fromJson(Map.from(result));
      }

      // Fallback: check if data is wrapped in 'data' field (standard structure)
      if (result.containsKey('data') && result['data'] != null) {
        return StaffAttendanceResponse.fromJson(Map.from(result['data']));
      }

      // Return empty response if no valid structure found
      return StaffAttendanceResponse();
    } catch (e, st) {
      debugPrint("Error fetching staff attendance: $e");
      debugPrint("Stack trace: $st");
      throw ApiException(e.toString());
    }
  }

  /// Submit staff attendance
  /// API: POST /api/staff/staff-attendance-store
  /// Payload: {
  ///   "date": "YYYY-MM-DD",
  ///   "holiday": null,
  ///   "attendance_data": [
  ///     {
  ///       "id": null | attendance_id,
  ///       "staff_id": "123",
  ///       "type": "1", (0 - absent, 1 - present, 3 - holiday, 4 - first half present and 5 second half present)
  ///       "reason": null | "reason text",
  ///       "leave_id": null
  ///     }
  ///   ],
  ///   "absent_notification": true
  /// }
  Future<void> submitStaffAttendance({
    required StaffAttendanceSubmissionPayload payload,
  }) async {
    try {
      await Api.post(
        url: Api.submitStaffAttendance,
        body: payload.toJson(),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
