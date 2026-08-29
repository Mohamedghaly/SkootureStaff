import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/currentPlan.dart';
import 'package:eschool_saas_staff/data/repositories/currentPlanRepository.dart';

// States
abstract class CurrentPlanState {}

class CurrentPlanInitial extends CurrentPlanState {}

class CurrentPlanFetchInProgress extends CurrentPlanState {}

class CurrentPlanFetchSuccess extends CurrentPlanState {
  final CurrentPlan plan;

  CurrentPlanFetchSuccess({required this.plan});
}

class CurrentPlanFetchFailure extends CurrentPlanState {
  final String errorMessage;

  CurrentPlanFetchFailure(this.errorMessage);
}

class CurrentPlanNoData extends CurrentPlanState {
  final String message;

  CurrentPlanNoData(this.message);
}

// Cubit
class CurrentPlanCubit extends Cubit<CurrentPlanState> {
  final CurrentPlanRepository _repository = CurrentPlanRepository();
  CurrentPlan? _cachedPlan;

  CurrentPlanCubit() : super(CurrentPlanInitial());

  /// Get cached current plan
  CurrentPlan? getCurrentPlan() => _cachedPlan;

  /// Fetch current transportation plan from API
  /// This API endpoint returns all plan details including:
  /// - shift_id, route, pickup_stop, duration, validity, etc.
  Future<void> fetchCurrentPlan({required int userId}) async {
    emit(CurrentPlanFetchInProgress());
    try {
      final response = await _repository.getCurrentPlan(userId: userId);

      if (response.error || response.data == null) {
        emit(CurrentPlanFetchFailure(response.message));
        return;
      }

      _cachedPlan = response.data;
      emit(CurrentPlanFetchSuccess(plan: response.data!));
    } catch (e) {
      debugPrint('[CurrentPlanCubit] Error fetching current plan: $e');
      emit(CurrentPlanFetchFailure(e.toString()));
    }
  }

  /// Clear cached data
  void clearData() {
    _cachedPlan = null;
    emit(CurrentPlanInitial());
  }

  /// Check if plan is loaded
  bool isPlanLoaded() => state is CurrentPlanFetchSuccess;
}
