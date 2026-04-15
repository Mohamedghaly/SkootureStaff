import 'package:eschool_saas_staff/data/models/currentPlan.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class CurrentPlanRepository {
  /// Fetch current transportation plan for a user
  /// This API returns all plan details including shift_id, route, pickup_stop, etc.
  Future<CurrentPlanResponse> getCurrentPlan({required int userId}) async {
    try {
      final result = await Api.post(
        url: Api.getCurrentPlan,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );

      return CurrentPlanResponse.fromJson(result);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
