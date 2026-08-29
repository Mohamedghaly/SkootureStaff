import 'package:eschool_saas_staff/data/models/certificateAssignment.dart';
import 'package:eschool_saas_staff/utils/api.dart';

/// Repository for certificate-related API operations.
class CertificateRepository {
  /// Fetches the list of certificate assignments for the current user.
  Future<List<CertificateAssignment>> fetchCertificateAssignments() async {
    try {
      final result = await Api.post(
        url: Api.getCertificateAssignments,
        useAuthToken: true,
        body: {},
      );

      return ((result['data'] ?? []) as List)
          .map(
            (json) => CertificateAssignment.fromJson(
              Map<String, dynamic>.from(json ?? {}),
            ),
          )
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Generates certificate HTML for a given template ID.
  /// Returns the raw HTML string to be rendered/printed.
  Future<String> generateCertificateHtml({
    required int certificateTemplateId,
  }) async {
    try {
      final htmlContent = await Api.postRaw(
        url: Api.generateCertificate,
        useAuthToken: true,
        body: {
          'id': certificateTemplateId,
          'school_code': Api.headers()['school-code'] ?? '',
        },
      );

      if (htmlContent.isEmpty) {
        throw ApiException('Empty certificate response');
      }

      return htmlContent;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
