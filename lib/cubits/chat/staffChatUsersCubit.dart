import 'package:eschool_saas_staff/data/models/models.dart';
import 'package:eschool_saas_staff/data/repositories/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum StaffChatUsersFetchStatus { initial, loading, success, failure }

enum StaffChatUsersSearchStatus { initial, loading, success, failure }

class StaffChatUsersState {
  final StaffChatUsersFetchStatus status;
  final StaffChatUsersSearchStatus searchStatus;
  final String? errorMessage;
  final ChatUsersResponse? chatUsersResponse;
  final ChatUsersResponse? searchChatUsersResponse;
  final bool loadMore;
  final bool searchLoadMore;

  const StaffChatUsersState({
    this.status = StaffChatUsersFetchStatus.initial,
    this.searchStatus = StaffChatUsersSearchStatus.initial,
    this.errorMessage,
    this.chatUsersResponse,
    this.searchChatUsersResponse,
    this.loadMore = false,
    this.searchLoadMore = false,
  });

  StaffChatUsersState copyWith({
    StaffChatUsersFetchStatus? status,
    StaffChatUsersSearchStatus? searchStatus,
    String? errorMessage,
    ChatUsersResponse? chatUsersResponse,
    ChatUsersResponse? searchChatUsersResponse,
    bool? loadMore,
    bool? searchLoadMore,
  }) {
    return StaffChatUsersState(
      status: status ?? this.status,
      searchStatus: searchStatus ?? this.searchStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      chatUsersResponse: chatUsersResponse ?? this.chatUsersResponse,
      searchChatUsersResponse:
          searchChatUsersResponse ?? this.searchChatUsersResponse,
      loadMore: loadMore ?? this.loadMore,
      searchLoadMore: searchLoadMore ?? this.searchLoadMore,
    );
  }
}

class StaffChatUsersCubit extends Cubit<StaffChatUsersState> {
  StaffChatUsersCubit() : super(const StaffChatUsersState());

  final _chatRepository = ChatRepository();

  void fetchChatUsers({
    required ChatUserRole role,
    int page = 1,
    String? childId,
    String? classSectionId,
  }) async {
    emit(state.copyWith(status: StaffChatUsersFetchStatus.loading));

    _chatRepository
        .getUsers(
      role: role,
      childId: childId,
      classSectionId: classSectionId,
      page: page,
    )
        .then((chatUsersResponse) {
      emit(state.copyWith(
        status: StaffChatUsersFetchStatus.success,
        chatUsersResponse: chatUsersResponse,
      ));
    }).catchError((e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: StaffChatUsersFetchStatus.failure,
        errorMessage: e.toString(),
      ));
    });
  }

  void searchChatUsers({
    required ChatUserRole role,
    int page = 1,
    String? childId,
    String? classSectionId,
    required String search,
  }) {
    emit(state.copyWith(searchStatus: StaffChatUsersSearchStatus.loading));

    _chatRepository
        .getUsers(
      role: role,
      childId: childId,
      classSectionId: classSectionId,
      page: page,
      search: search,
    )
        .then((chatUsersResponse) {
      emit(state.copyWith(
        searchStatus: StaffChatUsersSearchStatus.success,
        searchChatUsersResponse: chatUsersResponse,
      ));
    }).catchError((e) {
      if (isClosed) return;
      emit(state.copyWith(
        searchStatus: StaffChatUsersSearchStatus.failure,
        errorMessage: e.toString(),
      ));
    });
  }

  void clearSearch() {
    emit(state.copyWith(searchStatus: StaffChatUsersSearchStatus.initial));
  }

  bool get hasMore {
    if (state.status == StaffChatUsersFetchStatus.success) {
      return state.chatUsersResponse!.currentPage <
          state.chatUsersResponse!.lastPage;
    }
    return false;
  }

  bool get searchHasMore {
    if (state.searchStatus == StaffChatUsersSearchStatus.success) {
      return state.searchChatUsersResponse!.currentPage <
          state.searchChatUsersResponse!.lastPage;
    }
    return false;
  }

  Future<void> fetchMoreChatUsers({
    required ChatUserRole role,
    String? childId,
    String? classSectionId,
  }) async {
    if (state.status == StaffChatUsersFetchStatus.success && !state.loadMore) {
      emit(state.copyWith(loadMore: true));

      final old = state.chatUsersResponse!;

      await _chatRepository
          .getUsers(
        role: role,
        childId: childId,
        classSectionId: classSectionId,
        page: old.currentPage + 1,
      )
          .then((chatUsersResponse) {
        final chatUsers = old.chatUsers..addAll(chatUsersResponse.chatUsers);

        emit(
          state.copyWith(
            status: StaffChatUsersFetchStatus.success,
            chatUsersResponse: chatUsersResponse.copyWith(chatUsers: chatUsers),
            loadMore: false,
          ),
        );
      }).catchError((e) {
        if (isClosed) return;
        emit(state.copyWith(
          status: StaffChatUsersFetchStatus.failure,
          errorMessage: e.toString(),
        ));
      });
    }
  }
}
