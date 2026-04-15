import 'package:eschool_saas_staff/utils/api.dart';

class TripReportRepository {
  Future<Map<String, dynamic>> submitTripReport({
    required int routeVehicleHistoryId,
    required String description,
    int? pickupPointId, // Optional parameter for driver reports during trip
  }) async {
    try {
      final body = {
        'route_vehicle_history_id': routeVehicleHistoryId,
        'description': description,
      };

      // Add pickup_point_id only if provided (for driver mid-trip reports)
      if (pickupPointId != null) {
        body['pickup_point_id'] = pickupPointId;
      }

      final result = await Api.post(
        body: body,
        url: Api.storeTripReports,
        useAuthToken: true,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
