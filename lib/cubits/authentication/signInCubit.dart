import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInInProgress extends SignInState {}

class SignInSuccess extends SignInState {
  final String authToken;
  final UserDetails userDetails;
  final String schoolCode;

  SignInSuccess({
    required this.authToken,
    required this.userDetails,
    required this.schoolCode,
  });
}

class SignInFailure extends SignInState {
  final String errorMessage;

  SignInFailure(this.errorMessage);
}

class SignInCubit extends Cubit<SignInState> {
  final AuthRepository _authRepository = AuthRepository();

  SignInCubit() : super(SignInInitial());

  Future<void> signInUser({
    required String email,
    required String password,
    required String schoolCode,
  }) async {
    emit(SignInInProgress());

    try {
      final result = await _authRepository.loginUser(
        email: email,
        password: password,
        schoolCode: schoolCode,
      );

      emit(
        SignInSuccess(
          authToken: result.token,
          userDetails: result.userDetails,
          schoolCode: schoolCode,
        ),
      );
    } catch (e) {
      emit(SignInFailure(e.toString()));
    }
  }
}
