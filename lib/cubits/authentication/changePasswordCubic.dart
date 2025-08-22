import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChangePasswordState{}

class ChangePasswordInitial extends ChangePasswordState{}

class ChangePasswordProgress extends ChangePasswordState{}

class ChangePasswordSuccess extends ChangePasswordState{
  final String successMessage;
  ChangePasswordSuccess({required this.successMessage});
}

class ChangePasswordFailure extends ChangePasswordState{
  final String errorMessage;
  ChangePasswordFailure({required this.errorMessage});
}

class ChangePasswoedCubit extends Cubit<ChangePasswordState>{
  final AuthRepository _authRepository = AuthRepository();
  ChangePasswoedCubit() :super(ChangePasswordInitial());

  void changePassword({required String oldPassword, required String newPassword, required String confirmPassword})async{
    try{
      emit(ChangePasswordProgress());
      emit(ChangePasswordSuccess(successMessage: await _authRepository.changePassword(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)));
    }catch (e){
      emit(ChangePasswordFailure(errorMessage: e.toString()));
    }
  }

}