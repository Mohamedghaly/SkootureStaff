import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileProgress extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final UserDetails userDetails;
  final String successMessage;
  EditProfileSuccess({required this.userDetails, required this.successMessage});
}

class EditProfileFailure extends EditProfileState {
  final String errorMessage;

  EditProfileFailure({required this.errorMessage});
}

class EditProfileCubit extends Cubit<EditProfileState> {
  final AuthRepository _authRepository = AuthRepository();
  EditProfileCubit() : super(EditProfileInitial());

  void editProfile(
      {required String firstName,
      required String lastName,
      required String mobileNumber,
      required String email,
      required String dateOfBirth,
      required String currentAddress,
      required String permanentAddress,
      required String gender,
      String? image}) async {
    try {
      emit(EditProfileProgress());
      final result = await _authRepository.editProfile(
          firstName: firstName,
          lastName: lastName,
          mobileNumber: mobileNumber,
          email: email,
          dateOfBirth: dateOfBirth,
          currentAddress: currentAddress,
          permanentAddress: permanentAddress,
          gender: gender,
          image: image);
      emit(EditProfileSuccess(
          userDetails: result.userDetails,
          successMessage: result.successmessage));
    } catch (e) {
      emit(EditProfileFailure(errorMessage: e.toString()));
    }
  }
}
