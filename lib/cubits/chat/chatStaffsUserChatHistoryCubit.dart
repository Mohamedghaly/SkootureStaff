import 'package:eschool_saas_staff/data/models/models.dart';
import 'package:eschool_saas_staff/data/repositories/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StaffsUserChatHistoryState {}

class StaffsUserChatHistoryInitial extends StaffsUserChatHistoryState {}

class StaffsUserChatHistoryFetchInProgress extends StaffsUserChatHistoryState {}

class StaffsUserChatHistoryFetchSuccess extends StaffsUserChatHistoryState {
  final UserChatHistory userChatHistory;
  final bool loadMore;

  StaffsUserChatHistoryFetchSuccess({
    required this.userChatHistory,
    this.loadMore = false,
  });
}

class StaffsUserChatHistoryFetchFailure extends StaffsUserChatHistoryState {
  final String errorMessage;

  StaffsUserChatHistoryFetchFailure(this.errorMessage);
}

class StaffsUserChatHistoryCubit extends Cubit<StaffsUserChatHistoryState> {
  StaffsUserChatHistoryCubit() : super(StaffsUserChatHistoryInitial());

  final ChatRepository _chatRepository = ChatRepository();

  void fetchUserChatHistory({int page = 1}) async {
    emit(StaffsUserChatHistoryFetchInProgress());

    await _chatRepository
        .getUserChatHistory(role: ChatUserRole.staff, page: page)
        .then((userChatHistory) {
      emit(
        StaffsUserChatHistoryFetchSuccess(userChatHistory: userChatHistory),
      );
    }).catchError(
      (Object e) {
        if (isClosed) return;
        emit(StaffsUserChatHistoryFetchFailure(e.toString()));
      },
    );
  }

  bool get hasMore {
    if (state is StaffsUserChatHistoryFetchSuccess) {
      final history =
          (state as StaffsUserChatHistoryFetchSuccess).userChatHistory;

      return history.currentPage < history.lastPage;
    } else {
      return false;
    }
  }

  void fetchMoreUserChatHistory() async {
    if (state is StaffsUserChatHistoryFetchSuccess &&
        !(state as StaffsUserChatHistoryFetchSuccess).loadMore) {
      final oldHistory =
          (state as StaffsUserChatHistoryFetchSuccess).userChatHistory;

      emit(StaffsUserChatHistoryFetchSuccess(
        userChatHistory: oldHistory,
        loadMore: true,
      ));

      await _chatRepository
          .getUserChatHistory(
        role: ChatUserRole.teacher,
        page: oldHistory.currentPage + 1,
      )
          .then(
        (userChatHistory) {
          final newContacts = oldHistory.chatContacts
            ..addAll(userChatHistory.chatContacts);

          emit(
            StaffsUserChatHistoryFetchSuccess(
              userChatHistory:
                  userChatHistory.copyWith(chatContacts: newContacts),
              loadMore: false,
            ),
          );
        },
      ).catchError(
        (Object e) {
          emit(StaffsUserChatHistoryFetchFailure(e.toString()));
        },
      );
    }
  }

  void messageReceived({
    required String from,
    required String message,
    required String updatedAt,
    required bool incrementUnreadCount,
  }) async {
    if (state is StaffsUserChatHistoryFetchSuccess) {
      final history =
          (state as StaffsUserChatHistoryFetchSuccess).userChatHistory;

      final chatContact = history.chatContacts
          .where((e) => e.receiverId.toString() == from)
          .firstOrNull;

      /// message received from a chat contact that is not in the history
      if (chatContact == null) return;

      final updatedContact = chatContact.copyWith(
        lastMessage: message,
        updatedAt: updatedAt,
        unreadCount: incrementUnreadCount ? chatContact.unreadCount + 1 : null,
      );

      final newContacts = history.chatContacts
          .map((e) => e.receiverId.toString() == from ? e = updatedContact : e)
          .toList();

      emit(
        StaffsUserChatHistoryFetchSuccess(
          userChatHistory: history.copyWith(chatContacts: newContacts),
        ),
      );
    }
  }

  void updateUnreadCount(int receiverId, int count) {
    if (state is StaffsUserChatHistoryFetchSuccess) {
      final history =
          (state as StaffsUserChatHistoryFetchSuccess).userChatHistory;

      final chatContact = history.chatContacts
          .where((e) => e.user.id == receiverId)
          .firstOrNull;

      /// message received from a chat contact that is not in the history
      if (chatContact == null) return;

      final updatedContact = chatContact.copyWith(
        unreadCount: (chatContact.unreadCount - count < 0
            ? 0
            : chatContact.unreadCount - count),
      );

      final newContacts = history.chatContacts
          .map((e) => e.user.id == receiverId ? e = updatedContact : e)
          .toList();

      emit(
        StaffsUserChatHistoryFetchSuccess(
          userChatHistory: history.copyWith(chatContacts: newContacts),
        ),
      );
    }
  }

  void updateLastMessage(
    int receiverId,
    String lastMessage,
    DateTime lastMessageTime,
  ) {
    if (state is StaffsUserChatHistoryFetchSuccess) {
      final history =
          (state as StaffsUserChatHistoryFetchSuccess).userChatHistory;

      final chatContact = history.chatContacts
          .where((e) => e.user.id == receiverId)
          .firstOrNull;

      /// message received from a chat contact that is not in the history
      if (chatContact == null) return;

      final updatedContact = chatContact.copyWith(
        lastMessage: lastMessage,
        updatedAt: lastMessageTime.toIso8601String(),
      );

      final newContacts = history.chatContacts
          .map((e) => e.user.id == receiverId ? e = updatedContact : e)
          .toList();

      emit(
        StaffsUserChatHistoryFetchSuccess(
          userChatHistory: history.copyWith(chatContacts: newContacts),
        ),
      );
    }
  }
}
