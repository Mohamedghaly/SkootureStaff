import 'package:eschool_saas_staff/data/models/certificateAssignment.dart';
import 'package:eschool_saas_staff/data/repositories/certificateRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// States for the certificates cubit.
abstract class CertificatesState {}

class CertificatesInitial extends CertificatesState {}

class CertificatesFetchInProgress extends CertificatesState {}

class CertificatesFetchSuccess extends CertificatesState {
  final List<CertificateAssignment> certificates;

  CertificatesFetchSuccess({required this.certificates});
}

class CertificatesFetchFailure extends CertificatesState {
  final String errorMessage;

  CertificatesFetchFailure(this.errorMessage);
}

/// Cubit managing the certificate assignments list.
class CertificatesCubit extends Cubit<CertificatesState> {
  final CertificateRepository _certificateRepository;

  CertificatesCubit(this._certificateRepository)
      : super(CertificatesInitial());

  /// Fetches certificate assignments for the current staff user.
  Future<void> fetchCertificates() async {
    emit(CertificatesFetchInProgress());
    try {
      final certificates =
          await _certificateRepository.fetchCertificateAssignments();
      emit(CertificatesFetchSuccess(certificates: certificates));
    } catch (e) {
      emit(CertificatesFetchFailure(e.toString()));
    }
  }
}
