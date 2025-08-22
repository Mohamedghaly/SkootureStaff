import 'package:eschool_saas_staff/data/models/studentSubjectsResponse.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class StudentSubjectsRepository {
  Future<StudentSubjectsResponse> getStudentSubjects() async {
    try {
      final result = await Api.get(
        url: Api.getStudentSubjects,
        useAuthToken: true,
      );

      return StudentSubjectsResponse.fromJson(Map.from(result['data'] ?? {}));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
