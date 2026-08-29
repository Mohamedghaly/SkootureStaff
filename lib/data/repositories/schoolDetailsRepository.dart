import 'package:eschool_saas_staff/data/models/schoolDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/material.dart';

class Schooldetailsfetch {
  static Future<SchoolDetails> fetchSchoolDetails() async {
    try {
      final result = await Api.get(
        url: Api.schoolDetails,
        useAuthToken: true,
      );

      debugPrint("This is school details : ${result['data']}");

      final SchoolDetails schoolDetails =
          SchoolDetails.fromJson(result['data']);

      return schoolDetails;
    } catch (e, st) {
      debugPrint("this is School details error : ${st}");
      throw ApiException(e.toString());
    }
  }
}
