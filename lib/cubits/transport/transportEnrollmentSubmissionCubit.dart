import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/transportEnrollmentSubmission.dart';
import 'package:eschool_saas_staff/data/repositories/transportEnrollmentRepository.dart';

// States
abstract class TransportEnrollmentSubmissionState {}

class TransportEnrollmentSubmissionInitial
    extends TransportEnrollmentSubmissionState {}

class TransportEnrollmentSubmissionInProgress
    extends TransportEnrollmentSubmissionState {}

class TransportEnrollmentSubmissionSuccess
    extends TransportEnrollmentSubmissionState {
  final TransportEnrollmentSubmissionResponse response;

  TransportEnrollmentSubmissionSuccess({required this.response});
}

class TransportEnrollmentSubmissionFailure
    extends TransportEnrollmentSubmissionState {
  final String errorMessage;

  TransportEnrollmentSubmissionFailure(this.errorMessage);
}

// Cubit
class TransportEnrollmentSubmissionCubit
    extends Cubit<TransportEnrollmentSubmissionState> {
  final TransportEnrollmentRepository _repository =
      TransportEnrollmentRepository();

  TransportEnrollmentSubmissionCubit()
      : super(TransportEnrollmentSubmissionInitial());

  /// Submit transportation enrollment
  /// For staff app: paymentMethod is optional as fees are deducted from salary
  /// Set isChangeRoute to true when submitting a route change request
  Future<void> submitEnrollment({
    String? paymentMethod,
    required int userId,
    required int pickupPointId,
    required int transportationFeeId,
    required int shiftId,
    bool isChangeRoute = false,
  }) async {
    emit(TransportEnrollmentSubmissionInProgress());

    try {
      final request = TransportEnrollmentSubmissionRequest(
        paymentMethod: paymentMethod,
        userId: userId,
        pickupPointId: pickupPointId,
        transportationFeeId: transportationFeeId,
        shiftId: shiftId,
        isChangeRoute: isChangeRoute,
      );

      final response = await _repository.submitEnrollment(request: request);

      if (response.isSuccess) {
        emit(TransportEnrollmentSubmissionSuccess(response: response));
      } else {
        emit(TransportEnrollmentSubmissionFailure(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to submit enrollment'));
      }
    } catch (e) {
      emit(TransportEnrollmentSubmissionFailure(e.toString()));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(TransportEnrollmentSubmissionInitial());
  }
}
