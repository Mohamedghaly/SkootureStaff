import 'package:eschool_saas_staff/data/models/fee.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class FeeRepository {
  Future<List<Fee>> getFees() async {
    try {
      final result = await Api.get(url: Api.getFees);

      return ((result['data'] ?? []) as List)
          .map((fee) => Fee.fromJson(Map.from(fee ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<
          ({
            List<StudentDetails> students,
            int currentPage,
            int totalPage,
            double compolsoryFeeAmount,
            double optionalFeeAmount
          })>
      getStudentsFeePaymentStatus(
          {required int sessionYearId,
          required int status,
          required int feeId,
          int? page}) async {
    try {
      final result =
          await Api.get(url: Api.getStudentsFeeStatus, queryParameters: {
        "page": page ?? 1,
        "session_year_id": sessionYearId,
        "fees_id": feeId,
        "status": status
      });

      return (
        students: ((result['data']['data'] ?? []) as List)
            .map((studentDetails) =>
                StudentDetails.fromJson(Map.from(studentDetails ?? {})))
            .toList(),
        currentPage: result['data']['current_page'] as int,
        totalPage: result['data']['last_page'] as int,
        compolsoryFeeAmount:
            double.parse((result['compolsory_fees'] ?? 0.0).toString()),
        optionalFeeAmount:
            double.parse((result['optional_fees'] ?? 0.0).toString()),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> downloadStudentFeeReceipt(
      {required int studentId, required int feeId}) async {
    try {
      final result =
          await Api.get(url: Api.downloadStudentFeeReceipt, queryParameters: {
        "student_id": studentId,
        "fees_id": feeId,
      });

      return (result['pdf'] ?? "").toString();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
