import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SendPasswordResetEmailState {}

class SendPasswordResetEmailInitial extends SendPasswordResetEmailState {}

class SendPasswordResetEmailInProgress extends SendPasswordResetEmailState {}

class SendPasswordResetEmailSuccess extends SendPasswordResetEmailState {}

class SendPasswordResetEmailFailure extends SendPasswordResetEmailState {
  final String errorMessage;

  SendPasswordResetEmailFailure(this.errorMessage);
}

class SendPasswordResetEmailCubit extends Cubit<SendPasswordResetEmailState> {
  final AuthRepository _authRepository = AuthRepository();

  SendPasswordResetEmailCubit() : super(SendPasswordResetEmailInitial());

  void sendPasswordResetEmail(
      {required String email, required String schoolCode}) async {
    try {
      emit(SendPasswordResetEmailInProgress());
      await _authRepository.sendPasswordResetEmail(
          email: email, schoolCode: schoolCode);
      emit(SendPasswordResetEmailSuccess());
    } catch (e) {
      emit(SendPasswordResetEmailFailure(e.toString()));
    }
  }
}
