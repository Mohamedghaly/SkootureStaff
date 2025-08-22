import 'package:eschool_saas_staff/data/models/assignmentSubmission.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class AssignmentSubmissionsRepository {
  Future<List<AssignmentSubmission>> fetchAssignmentSubmissions({
    required int assignmentId,
  }) async {
    try {
      final body = {
        "assignment_id": assignmentId,
      };
      final result = await Api.get(
        url: Api.getReviewAssignment,
        useAuthToken: true,
        queryParameters: body,
      );

      return (result['data'] as List)
          .map(
            (reviewAssignment) =>
                AssignmentSubmission.fromJson(Map.from(reviewAssignment)),
          )
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> updateAssignmentSubmission({
    required int assignmentSubmissionId,
    required int assignmentSubmissionStatus,
    required int assignmentSubmissionPoints,
    required String assignmentSubmissionFeedBack,
  }) async {
    try {
      final body = {
        "assignment_submission_id": assignmentSubmissionId,
        "status": assignmentSubmissionStatus,
        "points": assignmentSubmissionPoints,
        "feedback": assignmentSubmissionFeedBack,
      };
      if (assignmentSubmissionPoints == 0 || assignmentSubmissionPoints == -1) {
        body.remove("points");
      }
      if (assignmentSubmissionFeedBack.isEmpty) {
        body.remove("feedback");
      }
      await Api.post(
        body: body,
        url: Api.updateReviewAssignment,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
