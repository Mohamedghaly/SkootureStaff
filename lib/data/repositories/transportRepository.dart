import 'package:eschool_saas_staff/data/models/pickupPoint.dart';
import 'package:eschool_saas_staff/data/models/transportDashboard.dart';
import 'package:eschool_saas_staff/data/models/transportFee.dart';
import 'package:eschool_saas_staff/data/models/transportShift.dart';
import 'package:eschool_saas_staff/data/models/vehicleAssignmentStatus.dart';
import 'package:eschool_saas_staff/data/models/trip.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/material.dart';

class TransportRepository {
  Future<List<PickupPoint>> getPickupPoints() async {
    try {
      final result = await Api.get(url: Api.getPickupPoints);
      return ((result['data'] ?? []) as List)
          .map((e) => PickupPoint.fromJson(Map<String, dynamic>.from(e ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<TransportShift>> getShifts({required int pickupPointId}) async {
    try {
      final result = await Api.get(
          url: Api.getTransportationShifts,
          queryParameters: {"pickup_point_id": pickupPointId});
      return ((result['data'] ?? []) as List)
          .map((e) =>
              TransportShift.fromJson(Map<String, dynamic>.from(e ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<TransportFeesResponse> getFees({required int pickupPointId}) async {
    try {
      final result = await Api.get(
          url: Api.getTransportationFees,
          queryParameters: {"pickup_point_id": pickupPointId});
      return TransportFeesResponse.fromJson(result);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<TransportDashboard> getDashboard({
    required int userId,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getTransportDashboard,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );

      return TransportDashboard.fromJson(
        Map<String, dynamic>.from(result['data'] ?? {}),
      );
    } catch (e, st) {
      debugPrint("this is the error: $e");
      debugPrint("this is the stack trace: $st");
      throw ApiException(e.toString());
    }
  }

  Future<VehicleAssignmentStatus> getVehicleAssignmentStatus({
    required int userId,
  }) async {
    try {
      final result = await Api.post(
        url: Api.getVehicleAssignmentStatus,
        useAuthToken: true,
        body: {
          'user_id': userId.toString(),
        },
      );

      return VehicleAssignmentStatus.fromJson(result);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Trip related methods
  Future<List<Trip>> getTrips() async {
    try {
      final result = await Api.get(
        url: Api.getTrips,
        useAuthToken: true,
      );

      return ((result['data'] ?? []) as List)
          .map((trip) => Trip.fromJson(Map<String, dynamic>.from(trip ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Trip>> getTripsByRoute({required int routeId}) async {
    try {
      final result = await Api.get(
        url: Api.getTrips,
        useAuthToken: true,
        queryParameters: {
          'route_id': routeId,
        },
      );

      return ((result['data'] ?? []) as List)
          .map((trip) => Trip.fromJson(Map<String, dynamic>.from(trip ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Trip> getTripDetails({required int tripId}) async {
    try {
      final result = await Api.get(
        url: Api.getTrips,
        useAuthToken: true,
        queryParameters: {
          'trip_id': tripId,
        },
      );

      final tripData = result['data'];
      if (tripData is List && tripData.isNotEmpty) {
        return Trip.fromJson(Map<String, dynamic>.from(tripData.first ?? {}));
      } else if (tripData is Map) {
        return Trip.fromJson(Map<String, dynamic>.from(tripData));
      } else {
        throw ApiException('No trip data found');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> startEndTrip({
    required int shiftId,
    required String pickupDrop, // "pickup" or "drop"
    required String startEnd, // "start" or "end"
    int? tripId, // Optional trip_id for ending trips
  }) async {
    try {
      final body = {
        'shift_id': shiftId.toString(),
        'pickup_drop': pickupDrop,
        'start_end': startEnd,
      };

      // Add trip_id to body when ending a trip
      if (tripId != null) {
        body['trip_id'] = tripId.toString();
      }

      final result = await Api.post(
        url: Api.startEndTrip,
        useAuthToken: true,
        body: body,
      );

      return result;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> createAttendance({
    required int routeVehicleId,
    required int pickupPointId,
    required int shiftId,
    required int pickupDrop, // 0 for pickup, 1 for drop
    required String date,
    required int tripId,
    required List<Map<String, dynamic>> records, // List of {user_id, status}
  }) async {
    try {
      final result = await Api.post(
        url: Api.createAttendance,
        useAuthToken: true,
        body: {
          'route_vehicle_id': routeVehicleId,
          'pickup_point_id': pickupPointId,
          'shift_id': shiftId,
          'pickup_drop': pickupDrop,
          'date': date,
          'trip_id': tripId,
          'records': records
        },
      );

      return result;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
