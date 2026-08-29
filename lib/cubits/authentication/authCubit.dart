import 'dart:convert';

import 'package:eschool_saas_staff/data/models/additionalUserDetails.dart';
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

  bool _isRefreshingProfile = false;

  /// Re-syncs the stored user details with the server (`GET profile`) so
  /// changes made from the admin panel show up without a re-login.
  ///
  /// The profile endpoint doesn't return everything the login response stored
  /// (the `staff_salary` breakdown and custom fields), so those are carried
  /// over from the current details. Fails silently — on any error the stored
  /// details simply stay in use.
  Future<void> refreshProfile() async {
    if (state is! Authenticated || _isRefreshingProfile) return;
    _isRefreshingProfile = true;
    try {
      final fresh = await authRepository.getProfile();
      if (state is! Authenticated) return; // signed out while fetching

      final current = (state as Authenticated).userDetails;
      final merged = fresh.copyWith(
        teacher: _withStoredSalaries(fresh.teacher, current.teacher),
        staff: _withStoredSalaries(fresh.staff, current.staff),
        customFields: (fresh.customFields ?? []).isEmpty
            ? current.customFields
            : fresh.customFields,
      );

      // Nothing changed — skip the write and the UI rebuild.
      if (jsonEncode(merged.toJson()) == jsonEncode(current.toJson())) return;

      await authRepository.setUserDetails(merged);
      emit(Authenticated(userDetails: merged));
    } catch (_) {
      // Offline / transient failure — keep showing the stored details.
    } finally {
      _isRefreshingProfile = false;
    }
  }

  /// The profile API's teacher/staff objects carry no `staff_salary` list
  /// (only login provides it) — keep the stored breakdown so payroll
  /// allowances/deductions don't get wiped by a profile re-sync.
  AdditionalUserDetails? _withStoredSalaries(
    AdditionalUserDetails? fresh,
    AdditionalUserDetails? stored,
  ) {
    if (fresh == null) return stored;
    if ((fresh.staffSalaries ?? []).isNotEmpty) return fresh;
    return fresh.copyWith(staffSalaries: stored?.staffSalaries);
  }

  /// Updates the user details in the auth state and persists to storage
  /// This method ensures all fields including custom fields are properly updated
  void updateuserDetail(UserDetails userdetails) {
    UserDetails currentUserDetails = (state as Authenticated).userDetails;

    currentUserDetails = currentUserDetails.copyWith(
      firstName: userdetails.firstName,
      lastName: userdetails.lastName,
      mobile: userdetails.mobile,
      countryCode: userdetails.countryCode,
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
