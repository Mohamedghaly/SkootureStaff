import 'package:eschool_saas_staff/data/models/vehicleAssignmentStatus.dart';
import 'package:eschool_saas_staff/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class VehicleAssignmentStatusState {}

class VehicleAssignmentStatusInitial extends VehicleAssignmentStatusState {}

class VehicleAssignmentStatusFetchInProgress
    extends VehicleAssignmentStatusState {}

class VehicleAssignmentStatusFetchSuccess extends VehicleAssignmentStatusState {
  final VehicleAssignmentStatus vehicleAssignmentStatus;

  VehicleAssignmentStatusFetchSuccess({required this.vehicleAssignmentStatus});
}

class VehicleAssignmentStatusFetchFailure extends VehicleAssignmentStatusState {
  final String errorMessage;

  VehicleAssignmentStatusFetchFailure(this.errorMessage);
}

class VehicleAssignmentStatusCubit extends Cubit<VehicleAssignmentStatusState> {
  final TransportRepository _transportRepository = TransportRepository();

  VehicleAssignmentStatusCubit() : super(VehicleAssignmentStatusInitial());

  Future<void> fetchVehicleAssignmentStatus({
    required int userId,
  }) async {
    emit(VehicleAssignmentStatusFetchInProgress());

    try {
      final vehicleAssignmentStatus =
          await _transportRepository.getVehicleAssignmentStatus(
        userId: userId,
      );

      emit(VehicleAssignmentStatusFetchSuccess(
          vehicleAssignmentStatus: vehicleAssignmentStatus));
    } catch (e) {
      emit(VehicleAssignmentStatusFetchFailure(e.toString()));
    }
  }

  // Helper method to check if user is assigned to vehicle
  bool isUserAssigned() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus
          .isAssigned;
    }
    return false;
  }

  // Helper method to check if assignment/plan is expired
  bool isExpired() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus
          .isExpired;
    }
    return false;
  }

  // Helper method to check if request is pending
  bool isPending() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus
          .isPending;
    }
    return false;
  }

  // Helper method to check if user is not assigned (false or null)
  bool isNotAssigned() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus
          .isNotAssigned;
    }
    return false;
  }

  // Helper method to check if user exists and API call was successful
  bool isValidUser() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus
          .isValidUser;
    }
    return false;
  }

  // Helper method to get assignment status
  String getAssignmentStatus() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus
          .assignmentStatus;
    }
    return 'unknown';
  }

  // Helper method to get status message
  String getStatusMessage() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus
          .message;
    }
    if (state is VehicleAssignmentStatusFetchFailure) {
      return (state as VehicleAssignmentStatusFetchFailure).errorMessage;
    }
    return 'Loading...';
  }

  // Helper method to get user-friendly status message
  String getUserFriendlyStatusMessage() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus
          .statusMessage;
    }
    if (state is VehicleAssignmentStatusFetchFailure) {
      return (state as VehicleAssignmentStatusFetchFailure).errorMessage;
    }
    return 'Loading...';
  }

  // Helper method to determine transport enrollment availability (always true if module is enabled)
  bool isTransportEnrollEnabled() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return true; // Always show if we have a successful API response
    }
    // Default to false if status is not loaded or failed
    return false;
  }

  // Helper method to check if assignment status has been loaded
  bool isStatusLoaded() {
    return state is VehicleAssignmentStatusFetchSuccess;
  }

  // Helper method to check if there was an error
  bool hasError() {
    return state is VehicleAssignmentStatusFetchFailure;
  }

  // Get the current vehicle assignment status object
  VehicleAssignmentStatus? getVehicleAssignmentStatus() {
    if (state is VehicleAssignmentStatusFetchSuccess) {
      return (state as VehicleAssignmentStatusFetchSuccess)
          .vehicleAssignmentStatus;
    }
    return null;
  }
}
