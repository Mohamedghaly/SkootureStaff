import 'package:eschool_saas_staff/data/models/routeStops.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class RouteStopsRepository {
  /// Fetches route stops for a specific user
  Future<RouteStopsResponse> getRouteStops({
    required int userId,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getRouteStops,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );

      return RouteStopsResponse.fromJson(result);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Helper method to get only the route stops data
  Future<RouteStopsData> getRouteStopsData({
    required int userId,
  }) async {
    try {
      final response = await getRouteStops(userId: userId);
      return response.data;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Helper method to get user's specific stop information
  Future<RouteStop?> getUserStop({
    required int userId,
  }) async {
    try {
      final data = await getRouteStopsData(userId: userId);
      return data.userStop;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Helper method to get route information
  Future<RouteInfo> getRouteInfo({
    required int userId,
  }) async {
    try {
      final data = await getRouteStopsData(userId: userId);
      return data.route;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
