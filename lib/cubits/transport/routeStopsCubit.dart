import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/routeStops.dart';
import 'package:eschool_saas_staff/data/repositories/routeStopsRepository.dart';

// States
abstract class RouteStopsState {}

class RouteStopsInitial extends RouteStopsState {}

class RouteStopsFetchInProgress extends RouteStopsState {
  final bool isRefresh;
  final RouteStopsData? previousData;

  RouteStopsFetchInProgress({
    this.isRefresh = false,
    this.previousData,
  });
}

class RouteStopsFetchSuccess extends RouteStopsState {
  final RouteStopsResponse response;
  final bool wasRefresh;

  RouteStopsFetchSuccess({
    required this.response,
    this.wasRefresh = false,
  });
}

class RouteStopsFetchFailure extends RouteStopsState {
  final String errorMessage;
  final bool wasRefresh;
  final RouteStopsData? previousData;

  RouteStopsFetchFailure(
    this.errorMessage, {
    this.wasRefresh = false,
    this.previousData,
  });
}

// Cubit
class RouteStopsCubit extends Cubit<RouteStopsState> {
  final RouteStopsRepository _repository = RouteStopsRepository();

  RouteStopsCubit() : super(RouteStopsInitial());

  Future<void> fetchRouteStops({
    required int userId,
    bool isRefresh = false,
  }) async {
    final currentData = state is RouteStopsFetchSuccess
        ? (state as RouteStopsFetchSuccess).response.data
        : null;

    emit(RouteStopsFetchInProgress(
      isRefresh: isRefresh,
      previousData: currentData,
    ));

    try {
      final response = await _repository.getRouteStops(userId: userId);
      emit(RouteStopsFetchSuccess(
        response: response,
        wasRefresh: isRefresh,
      ));
    } catch (e) {
      emit(RouteStopsFetchFailure(
        e.toString(),
        wasRefresh: isRefresh,
        previousData: currentData,
      ));
    }
  }

  Future<void> refreshRouteStops({required int userId}) async {
    await fetchRouteStops(userId: userId, isRefresh: true);
  }

  // Method to set data without API call (for navigation optimization)
  void setRouteData(RouteStopsResponse response) {
    emit(RouteStopsFetchSuccess(response: response, wasRefresh: false));
  }

  // Helper methods
  bool hasRouteData() {
    if (state is RouteStopsFetchSuccess) {
      return true;
    }
    if (state is RouteStopsFetchInProgress) {
      final inProgressState = state as RouteStopsFetchInProgress;
      return inProgressState.previousData != null;
    }
    if (state is RouteStopsFetchFailure) {
      final failureState = state as RouteStopsFetchFailure;
      return failureState.previousData != null;
    }
    return false;
  }

  RouteStopsData? getRouteData() {
    if (state is RouteStopsFetchSuccess) {
      return (state as RouteStopsFetchSuccess).response.data;
    }
    if (state is RouteStopsFetchInProgress) {
      final inProgressState = state as RouteStopsFetchInProgress;
      return inProgressState.previousData;
    }
    if (state is RouteStopsFetchFailure) {
      final failureState = state as RouteStopsFetchFailure;
      return failureState.previousData;
    }
    return null;
  }

  RouteInfo? getRouteInfo() {
    final data = getRouteData();
    return data?.route;
  }

  List<RouteStop> getRouteStops() {
    final data = getRouteData();
    return data?.stops ?? [];
  }

  RouteStop? getUserStop() {
    final data = getRouteData();
    return data?.userStop;
  }

  int getUserStopIndex() {
    final data = getRouteData();
    return data?.userStopIndex ?? -1;
  }

  String getErrorMessage() {
    if (state is RouteStopsFetchFailure) {
      return (state as RouteStopsFetchFailure).errorMessage;
    }
    return 'Unknown error occurred';
  }

  bool get isLoading => state is RouteStopsFetchInProgress;

  bool get isRefreshing {
    if (state is RouteStopsFetchInProgress) {
      return (state as RouteStopsFetchInProgress).isRefresh;
    }
    return false;
  }

  bool get hasError => state is RouteStopsFetchFailure;

  bool get hasData => hasRouteData();

  String get routeName => getRouteInfo()?.displayName ?? 'Unknown Route';

  String get vehicleName =>
      getRouteInfo()?.vehicleDisplayName ?? 'Unknown Vehicle';

  String get vehicleRegistration =>
      getRouteInfo()?.registrationDisplay ?? 'Unknown Registration';

  String get userStopName => getUserStop()?.displayName ?? 'Unknown Stop';

  String get userStopTime => getUserStop()?.timeDisplay ?? 'Unknown Time';
}
