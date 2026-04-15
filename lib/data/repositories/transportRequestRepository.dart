import 'package:eschool_saas_staff/data/models/transportRequest.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class TransportRequestRepository {
  /// Fetch transportation requests for a user
  Future<TransportRequestResponse> getTransportRequests({
    required int userId,
  }) async {
    try {
      final result = await Api.post(
        url: Api
            .getTransportRequests, // You'll need to add this to the Api class
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );

      return TransportRequestResponse.fromJson(result);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
