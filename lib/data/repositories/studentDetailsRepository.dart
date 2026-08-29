import 'package:eschool_saas_staff/data/models/studentDetailsResponse.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/material.dart';

class StudentDetailsRepository {
  Future<StudentDetailsResponse> getStudentDetails(
      {required int studentId}) async {
    try {
      final result = await Api.get(
        url: Api.getStudentDetails,
        useAuthToken: true,
        queryParameters: {
          'student_id': studentId,
        },
      );

      return StudentDetailsResponse.fromJson(Map.from(result['data'] ?? {}));
    } catch (e, st) {
      debugPrint("this is the error $e");
      debugPrint("this is the stack trace $st");
      throw ApiException(e.toString());
    }
  }
}
