import 'package:eschool_saas_staff/data/models/transportEnrollmentSubmission.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class TransportEnrollmentRepository {
  /// Submit transportation enrollment request
  Future<TransportEnrollmentSubmissionResponse> submitEnrollment({
    required TransportEnrollmentSubmissionRequest request,
  }) async {
    try {
      final result = await Api.post(
        url: Api.submitTransportEnrollment,
        useAuthToken: true,
        body: request.toJson(),
      );

      return TransportEnrollmentSubmissionResponse.fromJson(result);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
