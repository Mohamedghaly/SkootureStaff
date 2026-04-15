import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/repositories/tripReportRepository.dart';
import 'package:eschool_saas_staff/utils/api.dart';

abstract class TripReportState {}

class TripReportInitial extends TripReportState {}

class TripReportSubmitting extends TripReportState {}

class TripReportSubmitSuccess extends TripReportState {
  final String message;

  TripReportSubmitSuccess({required this.message});
}

class TripReportSubmitFailure extends TripReportState {
  final String errorMessage;

  TripReportSubmitFailure({required this.errorMessage});
}

class TripReportCubit extends Cubit<TripReportState> {
  final TripReportRepository _tripReportRepository = TripReportRepository();

  TripReportCubit() : super(TripReportInitial());

  Future<void> submitReport({
    required int tripId,
    required String description,
    int? pickupPointId, // Optional parameter for driver reports
  }) async {
    emit(TripReportSubmitting());

    try {
      final result = await _tripReportRepository.submitTripReport(
        routeVehicleHistoryId: tripId,
        description: description,
        pickupPointId: pickupPointId,
      );

      emit(TripReportSubmitSuccess(
        message: result['message'] ?? 'Report submitted successfully',
      ));
    } on ApiException catch (e) {
      emit(TripReportSubmitFailure(errorMessage: e.errorMessage));
    } catch (e) {
      emit(TripReportSubmitFailure(
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  void resetState() {
    emit(TripReportInitial());
  }
}
