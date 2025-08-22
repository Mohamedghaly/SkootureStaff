import 'package:eschool_saas_staff/data/models/models.dart';
import 'package:eschool_saas_staff/data/repositories/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ChatUsersFetchStatus { initial, loading, success, failure }

enum ChatUsersSearchStatus { initial, loading, success, failure }

class ChatUsersState {
  final ChatUsersFetchStatus status;
  final ChatUsersSearchStatus searchStatus;
  final String? errorMessage;
  final ChatUsersResponse? chatUsersResponse;
  final ChatUsersResponse? searchChatUsersResponse;
  final bool loadMore;
  final bool searchLoadMore;

  const ChatUsersState({
    this.status = ChatUsersFetchStatus.initial,
    this.searchStatus = ChatUsersSearchStatus.initial,
    this.errorMessage,
    this.chatUsersResponse,
    this.searchChatUsersResponse,
    this.loadMore = false,
    this.searchLoadMore = false,
  });

  ChatUsersState copyWith({
    ChatUsersFetchStatus? status,
    ChatUsersSearchStatus? searchStatus,
    String? errorMessage,
    ChatUsersResponse? chatUsersResponse,
    ChatUsersResponse? searchChatUsersResponse,
    bool? loadMore,
    bool? searchLoadMore,
  }) {
    return ChatUsersState(
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

class ChatUsersCubit extends Cubit<ChatUsersState> {
  ChatUsersCubit() : super(const ChatUsersState());

  final _chatRepository = ChatRepository();

  void fetchChatUsers({
    required ChatUserRole role,
    int page = 1,
    String? childId,
    String? classSectionId,
  }) async {
    emit(state.copyWith(status: ChatUsersFetchStatus.loading));

    _chatRepository
        .getUsers(
      role: role,
      childId: childId,
      classSectionId: classSectionId,
      page: page,
    )
        .then((chatUsersResponse) {
      emit(state.copyWith(
        status: ChatUsersFetchStatus.success,
        chatUsersResponse: chatUsersResponse,
      ));
    }).catchError((e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ChatUsersFetchStatus.failure,
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
    emit(state.copyWith(searchStatus: ChatUsersSearchStatus.loading));

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
        searchStatus: ChatUsersSearchStatus.success,
        searchChatUsersResponse: chatUsersResponse,
      ));
    }).catchError((e) {
      if (isClosed) return;
      emit(state.copyWith(
        searchStatus: ChatUsersSearchStatus.failure,
        errorMessage: e.toString(),
      ));
    });
  }

  void clearSearch() {
    emit(state.copyWith(searchStatus: ChatUsersSearchStatus.initial));
  }

  bool get hasMore {
    if (state.status == ChatUsersFetchStatus.success) {
      return state.chatUsersResponse!.currentPage <
          state.chatUsersResponse!.lastPage;
    }
    return false;
  }

  bool get searchHasMore {
    if (state.searchStatus == ChatUsersSearchStatus.success) {
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
    if (state.status == ChatUsersFetchStatus.success && !state.loadMore) {
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
            status: ChatUsersFetchStatus.success,
            chatUsersResponse: chatUsersResponse.copyWith(chatUsers: chatUsers),
            loadMore: false,
          ),
        );
      }).catchError((e) {
        if (isClosed) return;
        emit(state.copyWith(
          status: ChatUsersFetchStatus.failure,
          errorMessage: e.toString(),
        ));
      });
    }
  }
}
