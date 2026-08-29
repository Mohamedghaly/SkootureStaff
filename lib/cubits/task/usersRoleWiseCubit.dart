import 'package:eschool_saas_staff/data/models/staffMember.dart';
import 'package:eschool_saas_staff/data/repositories/taskRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── States ──────────────────────────────────────────────────

abstract class UsersRoleWiseState {}

class UsersRoleWiseInitial extends UsersRoleWiseState {}

class UsersRoleWiseFetchInProgress
    extends UsersRoleWiseState {}

class UsersRoleWiseFetchSuccess extends UsersRoleWiseState {
  final List<StaffMember> users;
  final int currentPage;
  final int totalPage;
  final bool fetchMoreInProgress;

  UsersRoleWiseFetchSuccess({
    required this.users,
    required this.currentPage,
    required this.totalPage,
    this.fetchMoreInProgress = false,
  });

  UsersRoleWiseFetchSuccess copyWith({
    List<StaffMember>? users,
    int? currentPage,
    int? totalPage,
    bool? fetchMoreInProgress,
  }) {
    return UsersRoleWiseFetchSuccess(
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      fetchMoreInProgress:
          fetchMoreInProgress ?? this.fetchMoreInProgress,
    );
  }
}

class UsersRoleWiseFetchFailure extends UsersRoleWiseState {
  final String errorMessage;

  UsersRoleWiseFetchFailure(this.errorMessage);
}

// ─── Cubit ───────────────────────────────────────────────────

/// Handles paginated, searchable user listing by role.
class UsersRoleWiseCubit
    extends Cubit<UsersRoleWiseState> {
  final TaskRepository _taskRepository = TaskRepository();

  UsersRoleWiseCubit() : super(UsersRoleWiseInitial());

  /// Whether more pages are available.
  bool hasMore() {
    if (state is UsersRoleWiseFetchSuccess) {
      final s = state as UsersRoleWiseFetchSuccess;
      return s.currentPage < s.totalPage;
    }
    return false;
  }

  /// Fetches users from page 1 (resets list).
  void getUsers({String? roleName, String? search}) async {
    try {
      emit(UsersRoleWiseFetchInProgress());
      final result =
          await _taskRepository.getUsersRoleWise(
        page: 1,
        roleName: roleName,
        search: search,
      );
      emit(UsersRoleWiseFetchSuccess(
        users: result.users,
        currentPage: result.currentPage,
        totalPage: result.totalPage,
      ));
    } catch (e) {
      emit(UsersRoleWiseFetchFailure(e.toString()));
    }
  }

  /// Fetches the next page and appends to the list.
  void fetchMore({
    String? roleName,
    String? search,
  }) async {
    if (state is! UsersRoleWiseFetchSuccess) return;
    final current = state as UsersRoleWiseFetchSuccess;

    if (current.fetchMoreInProgress) return;
    if (current.currentPage >= current.totalPage) return;

    emit(current.copyWith(fetchMoreInProgress: true));

    try {
      final result =
          await _taskRepository.getUsersRoleWise(
        page: current.currentPage + 1,
        roleName: roleName,
        search: search,
      );
      emit(UsersRoleWiseFetchSuccess(
        users: [...current.users, ...result.users],
        currentPage: result.currentPage,
        totalPage: result.totalPage,
      ));
    } catch (e) {
      // Revert loading state on failure.
      emit(current.copyWith(fetchMoreInProgress: false));
    }
  }
}
