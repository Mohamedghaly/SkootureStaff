import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/currentPlanRepository.dart';

// States
abstract class TransportPlanDetailsState {}

class TransportPlanDetailsInitial extends TransportPlanDetailsState {}

class TransportPlanDetailsFetchInProgress extends TransportPlanDetailsState {}

class TransportPlanDetailsFetchSuccess extends TransportPlanDetailsState {
  final TransportPlanDetails planDetails;

  TransportPlanDetailsFetchSuccess({required this.planDetails});
}

class TransportPlanDetailsFetchFailure extends TransportPlanDetailsState {
  final String errorMessage;

  TransportPlanDetailsFetchFailure(this.errorMessage);
}

class TransportPlanDetailsNoData extends TransportPlanDetailsState {
  final String message;

  TransportPlanDetailsNoData(this.message);
}

// Cubit
class TransportPlanDetailsCubit extends Cubit<TransportPlanDetailsState> {
  final CurrentPlanRepository _currentPlanRepository = CurrentPlanRepository();
  TransportPlanDetails? _cachedPlanDetails;

  TransportPlanDetailsCubit() : super(TransportPlanDetailsInitial());

  /// Get cached plan details
  TransportPlanDetails? getPlanDetails() => _cachedPlanDetails;

  /// Fetch plan details from Current Plan API (transport/plans/current)
  /// This API contains all the data including shift ID, route, pickup stop, etc.
  Future<void> fetchPlanDetails({required int userId}) async {
    emit(TransportPlanDetailsFetchInProgress());
    try {
      final response =
          await _currentPlanRepository.getCurrentPlan(userId: userId);

      if (response.error || response.data == null) {
        emit(TransportPlanDetailsFetchFailure(response.message));
        return;
      }

      final plan = response.data!;

      // Convert CurrentPlan to TransportPlanDetails
      final planDetails = TransportPlanDetails(
        routeName: plan.route?.name,
        pickupStop: plan.pickupStop != null
            ? PlanPickupStopAdapter(
                id: plan.pickupStop!.id,
                name: plan.pickupStop!.name,
              )
            : null,
        duration: plan.duration,
        validFrom: plan.validFrom,
        validTo: plan.validTo,
        shiftId: plan.shiftId,
        paymentId: plan.paymentId,
        totalFee: plan.totalFee,
        paymentMode: plan.paymentMode,
        shiftName: plan.shift?.name,
        shiftTimeWindow: plan.shift?.timeWindow,
        estimatedPickupTime: plan.estimatedPickupTime,
        vehicleId: plan.vehicleId,
        vehicleName: plan.vehicle?.vehicleName,
        vehicleRegistration: plan.vehicle?.vehicleRegistration,
      );

      _cachedPlanDetails = planDetails;
      emit(TransportPlanDetailsFetchSuccess(planDetails: planDetails));
    } catch (e) {
      emit(TransportPlanDetailsFetchFailure(e.toString()));
    }
  }

  /// Clear cached data
  void clearData() {
    _cachedPlanDetails = null;
    emit(TransportPlanDetailsInitial());
  }
}

/// Model for Transport Plan Details
/// Contains all data from the current plan API response
class TransportPlanDetails {
  final String? routeName;
  final PlanPickupStopAdapter? pickupStop;
  final String? duration;
  final String? validFrom;
  final String? validTo;
  final int? shiftId;
  final int? paymentId;
  final String? totalFee;
  final String? paymentMode;
  final String? shiftName;
  final String? shiftTimeWindow;
  final String? estimatedPickupTime;
  final int? vehicleId;
  final String? vehicleName;
  final String? vehicleRegistration;

  TransportPlanDetails({
    this.routeName,
    this.pickupStop,
    this.duration,
    this.validFrom,
    this.validTo,
    this.shiftId,
    this.paymentId,
    this.totalFee,
    this.paymentMode,
    this.shiftName,
    this.shiftTimeWindow,
    this.estimatedPickupTime,
    this.vehicleId,
    this.vehicleName,
    this.vehicleRegistration,
  });

  /// Helper getter to create a simple route info object for display
  /// Returns null if route name is not available
  SimpleRouteInfo? get route {
    if (routeName != null) {
      return SimpleRouteInfo(name: routeName);
    }
    return null;
  }
}

/// Simple route info class for display purposes
class SimpleRouteInfo {
  final String? name;

  SimpleRouteInfo({this.name});
}

/// Adapter class to make PlanPickupStop compatible with existing UI code
class PlanPickupStopAdapter {
  final int? id;
  final String? name;

  PlanPickupStopAdapter({this.id, this.name});
}
