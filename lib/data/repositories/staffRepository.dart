import 'dart:convert';

import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/foundation.dart';

class StaffRepository {
  Future<List<UserDetails>> getStaffs({String? search, int? status}) async {
    try {
      final result = await Api.get(
          url: Api.getStaffs,
          queryParameters: {"search": search, "status": status});

      return ((result['data'] ?? []) as List)
          .map((staff) => UserDetails.fromJson(Map.from(staff ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Downloads the staff ID card PDF as decoded bytes.
  Future<Uint8List> downloadIdCard() async {
    try {
      final result = await Api.get(
        url: Api.downloadStaffIdCard,
        useAuthToken: true,
      );

      final pdfData = result['pdf'];
      if (pdfData == null || pdfData.toString().isEmpty) {
        throw ApiException(
          result['message']?.toString() ?? defaultErrorMessageKey,
        );
      }

      return base64Decode(pdfData.toString());
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
