import 'package:eschool_saas_staff/data/models/trip.dart';
import 'package:eschool_saas_staff/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TripsState {}

class TripsInitial extends TripsState {}

class TripsFetchInProgress extends TripsState {}

class TripsFetchSuccess extends TripsState {
  final List<Trip> trips;

  TripsFetchSuccess({required this.trips});
}

class TripsFetchFailure extends TripsState {
  final String errorMessage;

  TripsFetchFailure(this.errorMessage);
}

class TripStartInProgress extends TripsState {}

class TripStartSuccess extends TripsState {
  final String message;
  final int? tripId;

  TripStartSuccess({required this.message, this.tripId});
}

class TripStartFailure extends TripsState {
  final String errorMessage;

  TripStartFailure(this.errorMessage);
}

class AttendanceCreateInProgress extends TripsState {}

class AttendanceCreateSuccess extends TripsState {
  final String message;

  AttendanceCreateSuccess({required this.message});
}

class AttendanceCreateFailure extends TripsState {
  final String errorMessage;

  AttendanceCreateFailure(this.errorMessage);
}

class TripDetailsFetchInProgress extends TripsState {}

class TripDetailsFetchSuccess extends TripsState {
  final Trip trip;

  TripDetailsFetchSuccess({required this.trip});
}

class TripDetailsFetchFailure extends TripsState {
  final String errorMessage;

  TripDetailsFetchFailure(this.errorMessage);
}

class TripCompleteInProgress extends TripsState {}

class TripCompleteSuccess extends TripsState {
  final String message;
  final int? tripId;

  TripCompleteSuccess({required this.message, this.tripId});
}

class TripCompleteFailure extends TripsState {
  final String errorMessage;

  TripCompleteFailure(this.errorMessage);
}

class TripsCubit extends Cubit<TripsState> {
  final TransportRepository _transportRepository = TransportRepository();

  TripsCubit() : super(TripsInitial());

  Future<void> fetchTrips() async {
    emit(TripsFetchInProgress());
    try {
      final trips = await _transportRepository.getTrips();
      emit(TripsFetchSuccess(trips: trips));
    } catch (e) {
      emit(TripsFetchFailure(e.toString()));
    }
  }

  // Helper methods to filter trips by status
  List<Trip> getUpcomingTrips() {
    if (state is TripsFetchSuccess) {
      return (state as TripsFetchSuccess)
          .trips
          .where((trip) => trip.isUpcoming)
          .toList();
    }
    return [];
  }

  List<Trip> getInProgressTrips() {
    if (state is TripsFetchSuccess) {
      return (state as TripsFetchSuccess)
          .trips
          .where((trip) => trip.isInProgress)
          .toList();
    }
    return [];
  }

  List<Trip> getCompletedTrips() {
    if (state is TripsFetchSuccess) {
      return (state as TripsFetchSuccess)
          .trips
          .where((trip) => trip.isCompleted)
          .toList();
    }
    return [];
  }

  List<Trip> getAllTrips() {
    if (state is TripsFetchSuccess) {
      return (state as TripsFetchSuccess).trips;
    }
    return [];
  }

  Future<void> fetchTripDetails({required int tripId}) async {
    emit(TripDetailsFetchInProgress());
    try {
      final trip = await _transportRepository.getTripDetails(tripId: tripId);
      emit(TripDetailsFetchSuccess(trip: trip));
    } catch (e) {
      emit(TripDetailsFetchFailure(e.toString()));
    }
  }

  Future<void> startTrip({
    required int shiftId,
    required String pickupDrop,
    int? routeId, // Optional route ID for refreshing specific route trips
  }) async {
    emit(TripStartInProgress());
    try {
      final result = await _transportRepository.startEndTrip(
        shiftId: shiftId,
        pickupDrop: pickupDrop,
        startEnd: 'start',
      );

      final message = result['message'] ?? 'Trip started successfully';
      final tripId = result['data']?['trip_id'];

      emit(TripStartSuccess(message: message, tripId: tripId));
    } catch (e) {
      emit(TripStartFailure(e.toString()));
    }
  }

  Future<void> endTrip({
    required int shiftId,
    required String pickupDrop,
    int? routeId, // Optional route ID for refreshing specific route trips
    int? tripId, // Optional trip_id for ending trips
  }) async {
    emit(TripStartInProgress());
    try {
      final result = await _transportRepository.startEndTrip(
        shiftId: shiftId,
        pickupDrop: pickupDrop,
        startEnd: 'end',
        tripId: tripId, // Pass the trip_id when ending trips
      );

      final message = result['message'] ?? 'Trip ended successfully';
      final returnedTripId = result['data']?['trip_id'];

      emit(TripStartSuccess(message: message, tripId: returnedTripId));
    } catch (e) {
      emit(TripStartFailure(e.toString()));
    }
  }

  Future<void> createAttendance({
    required int routeVehicleId,
    required int pickupPointId,
    required int shiftId,
    required int pickupDrop,
    required String date,
    required int tripId,
    required List<Map<String, dynamic>> records,
  }) async {
    emit(AttendanceCreateInProgress());
    try {
      final result = await _transportRepository.createAttendance(
        routeVehicleId: routeVehicleId,
        pickupPointId: pickupPointId,
        shiftId: shiftId,
        pickupDrop: pickupDrop,
        date: date,
        tripId: tripId,
        records: records,
      );

      final message = result['message'] ?? 'Attendance created successfully';
      emit(AttendanceCreateSuccess(message: message));

      // Note: Trip refresh is handled in the UI layer after attendance creation
    } catch (e) {
      emit(AttendanceCreateFailure(e.toString()));
    }
  }

  Future<void> completeTrip({required int tripId}) async {
    emit(TripCompleteInProgress());
    try {
      // First get the trip details to extract the required parameters for the API
      final trip = await _transportRepository.getTripDetails(tripId: tripId);

      // Convert trip type to API format
      String pickupDrop =
          trip.type.toLowerCase() == 'pickup' ? 'pickup' : 'drop';

      final result = await _transportRepository.startEndTrip(
        shiftId: trip.shiftTime.id,
        pickupDrop: pickupDrop,
        startEnd: 'end',
        tripId: tripId, // Pass the trip_id for ending trips
      );

      final message = result['message'] ?? 'Trip completed successfully';
      final returnedTripId = result['data']?['trip_id'];

      emit(TripCompleteSuccess(message: message, tripId: returnedTripId));
    } catch (e) {
      emit(TripCompleteFailure(e.toString()));
    }
  }
}
