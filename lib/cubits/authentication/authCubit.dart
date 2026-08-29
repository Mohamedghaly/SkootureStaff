import 'package:eschool_saas_staff/data/models/staffSalary.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserDetails userDetails;

  Authenticated({required this.userDetails});
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository = AuthRepository();

  AuthCubit() : super(AuthInitial()) {
    _checkIsAuthenticated();
  }

  void _checkIsAuthenticated() {
    if (AuthRepository.getIsLogIn()) {
      emit(
        Authenticated(userDetails: AuthRepository.getUserDetails()),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  void authenticateUser({
    required String authToken,
    required UserDetails userDetails,
    required String schoolCode,
  }) {
    //
    authRepository.schoolCode = schoolCode;
    authRepository.setAuthToken(authToken);
    authRepository.setUserDetails(userDetails);
    authRepository.setIsLogIn(true);

    // Store FCM token from login response
    if (userDetails.fcmId != null && userDetails.fcmId!.isNotEmpty) {
      authRepository.setFcmToken(userDetails.fcmId!);
    }

    //emit new state
    emit(
      Authenticated(userDetails: userDetails),
    );
  }

  UserDetails getUserDetails() {
    if (state is Authenticated) {
      return (state as Authenticated).userDetails;
    }
    return UserDetails.fromJson({});
  }

  bool isTeacher() {
    if (state is Authenticated) {
      return (state as Authenticated).userDetails.teacher?.id != null;
    }
    return false;
  }

  bool isDriver() {
    if (state is Authenticated) {
      final userDetails = (state as Authenticated).userDetails;
      final roles = userDetails.getRoles().toLowerCase();
      return roles.contains('driver') || roles.contains('helper');
    }
    return false;
  }

  void signOut() {
    authRepository.signOutUser();
    emit(Unauthenticated());
  }

  /// Updates the user details in the auth state and persists to storage
  /// This method ensures all fields including custom fields are properly updated
  void updateuserDetail(UserDetails userdetails) {
    UserDetails currentUserDetails = (state as Authenticated).userDetails;

    currentUserDetails = currentUserDetails.copyWith(
      firstName: userdetails.firstName,
      lastName: userdetails.lastName,
      mobile: userdetails.mobile,
      email: userdetails.email,
      dob: userdetails.dob,
      currentAddress: userdetails.currentAddress,
      permanentAddress: userdetails.permanentAddress,
      gender: userdetails.gender,
      image: userdetails.image,
      fullName: userdetails.fullName,
      customFields: userdetails.customFields, // Critical: Update custom fields
    );
    authRepository.setUserDetails(currentUserDetails);

    emit(Authenticated(userDetails: currentUserDetails));
  }

  List<StaffSalary> getAllowances() {
    if (state is Authenticated) {
      final UserDetails userDetails = (state as Authenticated).userDetails;

      return isTeacher()
          ? (userDetails.teacher?.staffSalaries ?? []).where((staffSalary) {
              return (staffSalary.payRollSetting?.isAllowance() ?? false);
            }).toList()
          : (userDetails.staff?.staffSalaries ?? [])
              .where((staffSalary) =>
                  (staffSalary.payRollSetting?.isAllowance() ?? false))
              .toList();
    }
    return [];
  }

  List<StaffSalary> getDeductions() {
    if (state is Authenticated) {
      final UserDetails userDetails = (state as Authenticated).userDetails;
      return isTeacher()
          ? (userDetails.teacher?.staffSalaries ?? [])
              .where((staffSalary) =>
                  (staffSalary.payRollSetting?.isDeduction() ?? false))
              .toList()
          : (userDetails.staff?.staffSalaries ?? [])
              .where((staffSalary) =>
                  (staffSalary.payRollSetting?.isDeduction() ?? false))
              .toList();
    }
    return [];
  }
}
