import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/userDetailsRepository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UsersByRoleState {}

class UsersByRoleInitial extends UsersByRoleState {}

class UsersByRoleInProgress extends UsersByRoleState {}

class UsersByRoleSuccess extends UsersByRoleState {
  final int totalPage;
  final int currentPage;
  final List<UserDetails> users;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;

  UsersByRoleSuccess(
      {required this.currentPage,
      required this.users,
      required this.fetchMoreError,
      required this.fetchMoreInProgress,
      required this.totalPage});

  UsersByRoleSuccess copyWith(
      {int? currentPage,
      bool? fetchMoreError,
      bool? fetchMoreInProgress,
      int? totalPage,
      List<UserDetails>? users}) {
    return UsersByRoleSuccess(
        currentPage: currentPage ?? this.currentPage,
        users: users ?? this.users,
        fetchMoreError: fetchMoreError ?? this.fetchMoreError,
        fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
        totalPage: totalPage ?? this.totalPage);
  }
}

class UsersByRoleFailure extends UsersByRoleState {
  final String errorMessage;

  UsersByRoleFailure(this.errorMessage);
}

class UsersByRoleCubit extends Cubit<UsersByRoleState> {
  final UserDetailsRepository _userDetailsRepository = UserDetailsRepository();

  UsersByRoleCubit() : super(UsersByRoleInitial());

  void getUsersByRole(
      {required List<String> roles, String? search, String? type}) async {
    emit(UsersByRoleInProgress());
    try {
      final result = await _userDetailsRepository.getUsersByRole(
          roles: roles, search: search, type: type);
      emit(UsersByRoleSuccess(
          currentPage: result.currentPage,
          users: result.users,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          totalPage: result.totalPage));
    } catch (e) {
      emit(UsersByRoleFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is UsersByRoleSuccess) {
      return (state as UsersByRoleSuccess).currentPage <
          (state as UsersByRoleSuccess).totalPage;
    }
    return false;
  }

  void fetchMore(
      {required List<String> roles, String? search, String? type}) async {
    //
    if (state is UsersByRoleSuccess) {
      if ((state as UsersByRoleSuccess).fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as UsersByRoleSuccess).copyWith(fetchMoreInProgress: true));

        final result = await _userDetailsRepository.getUsersByRole(
            roles: roles,
            search: search,
            type: type,
            page: (state as UsersByRoleSuccess).currentPage + 1);

        final currentState = (state as UsersByRoleSuccess);
        List<UserDetails> users = currentState.users;

        users.addAll(result.users);

        emit(UsersByRoleSuccess(
            currentPage: result.currentPage,
            fetchMoreError: false,
            fetchMoreInProgress: false,
            totalPage: result.totalPage,
            users: users));
      } catch (e) {
        emit((state as UsersByRoleSuccess)
            .copyWith(fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }
}
