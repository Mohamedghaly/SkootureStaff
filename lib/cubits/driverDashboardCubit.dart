import 'package:eschool_saas_staff/data/models/driverDashboardResponse.dart';
import 'package:eschool_saas_staff/data/repositories/driverRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DriverDashboardState {}

class DriverDashboardInitial extends DriverDashboardState {}

class DriverDashboardFetchInProgress extends DriverDashboardState {}

class DriverDashboardFetchSuccess extends DriverDashboardState {
  final DriverDashboardData dashboardData;

  DriverDashboardFetchSuccess({required this.dashboardData});
}

class DriverDashboardFetchFailure extends DriverDashboardState {
  final String errorMessage;

  DriverDashboardFetchFailure(this.errorMessage);
}

class DriverDashboardCubit extends Cubit<DriverDashboardState> {
  final DriverRepository _driverRepository = DriverRepository();

  DriverDashboardCubit() : super(DriverDashboardInitial());

  void getDriverDashboard() async {
    try {
      emit(DriverDashboardFetchInProgress());
      final dashboardData = await _driverRepository.getDriverDashboard();
      emit(DriverDashboardFetchSuccess(dashboardData: dashboardData));
    } catch (e) {
      emit(DriverDashboardFetchFailure(e.toString()));
    }
  }

  DriverDashboardData? getDashboardData() {
    if (state is DriverDashboardFetchSuccess) {
      return (state as DriverDashboardFetchSuccess).dashboardData;
    }
    return null;
  }
}
