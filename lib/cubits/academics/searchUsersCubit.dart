import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/userDetailsRepository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SearchUsersState {}

class SearchUsersInitial extends SearchUsersState {}

class SearchUsersInProgress extends SearchUsersState {}

class SearchUsersSuccess extends SearchUsersState {
  final int totalPage;
  final int currentPage;
  final List<UserDetails> users;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;

  SearchUsersSuccess(
      {required this.currentPage,
      required this.users,
      required this.fetchMoreError,
      required this.fetchMoreInProgress,
      required this.totalPage});

  SearchUsersSuccess copyWith(
      {int? currentPage,
      bool? fetchMoreError,
      bool? fetchMoreInProgress,
      int? totalPage,
      List<UserDetails>? users}) {
    return SearchUsersSuccess(
        currentPage: currentPage ?? this.currentPage,
        users: users ?? this.users,
        fetchMoreError: fetchMoreError ?? this.fetchMoreError,
        fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
        totalPage: totalPage ?? this.totalPage);
  }
}

class SearchUsersFailure extends SearchUsersState {
  final String errorMessage;

  SearchUsersFailure(this.errorMessage);
}

class SearchUsersCubit extends Cubit<SearchUsersState> {
  final UserDetailsRepository _userDetailsRepository = UserDetailsRepository();

  SearchUsersCubit() : super(SearchUsersInitial());

  void searchUsers({required String search}) async {
    emit(SearchUsersInProgress());
    try {
      final result = await _userDetailsRepository.searchUsers(search: search);
      emit(SearchUsersSuccess(
          currentPage: result.currentPage,
          users: result.users,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          totalPage: result.totalPage));
    } catch (e) {
      emit(SearchUsersFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is SearchUsersSuccess) {
      return (state as SearchUsersSuccess).currentPage <
          (state as SearchUsersSuccess).totalPage;
    }
    return false;
  }

  void fetchMore({required String search}) async {
    //
    if (state is SearchUsersSuccess) {
      if ((state as SearchUsersSuccess).fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as SearchUsersSuccess).copyWith(fetchMoreInProgress: true));

        final result = await _userDetailsRepository.searchUsers(
            search: search,
            page: (state as SearchUsersSuccess).currentPage + 1);

        final currentState = (state as SearchUsersSuccess);
        List<UserDetails> users = currentState.users;

        users.addAll(result.users);

        emit(SearchUsersSuccess(
            currentPage: result.currentPage,
            fetchMoreError: false,
            fetchMoreInProgress: false,
            totalPage: result.totalPage,
            users: users));
      } catch (e) {
        emit((state as SearchUsersSuccess)
            .copyWith(fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }
}
