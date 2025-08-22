import 'package:eschool_saas_staff/data/models/models.dart';
import 'package:eschool_saas_staff/data/repositories/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ParentsUserChatHistoryState {}

class ParentsUserChatHistoryInitial extends ParentsUserChatHistoryState {}

class ParentsUserChatHistoryFetchInProgress
    extends ParentsUserChatHistoryState {}

class ParentsUserChatHistoryFetchSuccess extends ParentsUserChatHistoryState {
  final UserChatHistory userChatHistory;
  final bool loadMore;

  ParentsUserChatHistoryFetchSuccess({
    required this.userChatHistory,
    this.loadMore = false,
  });
}

class ParentsUserChatHistoryFetchFailure extends ParentsUserChatHistoryState {
  final String errorMessage;

  ParentsUserChatHistoryFetchFailure(this.errorMessage);
}

class ParentsUserChatHistoryCubit extends Cubit<ParentsUserChatHistoryState> {
  ParentsUserChatHistoryCubit() : super(ParentsUserChatHistoryInitial());

  final ChatRepository _chatRepository = ChatRepository();

  void fetchUserChatHistory({int page = 1}) async {
    emit(ParentsUserChatHistoryFetchInProgress());

    await _chatRepository
        .getUserChatHistory(role: ChatUserRole.guardian, page: page)
        .then(
          (userChatHistory) => emit(
            ParentsUserChatHistoryFetchSuccess(
                userChatHistory: userChatHistory),
          ),
        )
        .catchError(
      (Object e) {
        if (isClosed) return;
        emit(ParentsUserChatHistoryFetchFailure(e.toString()));
      },
    );
  }

  bool get hasMore {
    if (state is ParentsUserChatHistoryFetchSuccess) {
      final history =
          (state as ParentsUserChatHistoryFetchSuccess).userChatHistory;

      return history.currentPage < history.lastPage;
    } else {
      return false;
    }
  }

  void fetchMoreUserChatHistory() async {
    if (state is ParentsUserChatHistoryFetchSuccess &&
        !(state as ParentsUserChatHistoryFetchSuccess).loadMore) {
      final oldHistory =
          (state as ParentsUserChatHistoryFetchSuccess).userChatHistory;

      emit(ParentsUserChatHistoryFetchSuccess(
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
            ParentsUserChatHistoryFetchSuccess(
              userChatHistory:
                  userChatHistory.copyWith(chatContacts: newContacts),
              loadMore: false,
            ),
          );
        },
      ).catchError(
        (Object e) {
          emit(ParentsUserChatHistoryFetchFailure(e.toString()));
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
    if (state is ParentsUserChatHistoryFetchSuccess) {
      final history =
          (state as ParentsUserChatHistoryFetchSuccess).userChatHistory;

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
        ParentsUserChatHistoryFetchSuccess(
          userChatHistory: history.copyWith(chatContacts: newContacts),
        ),
      );
    }
  }

  void updateUnreadCount(int receiverId, int count) {
    if (state is ParentsUserChatHistoryFetchSuccess) {
      final history =
          (state as ParentsUserChatHistoryFetchSuccess).userChatHistory;

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
        ParentsUserChatHistoryFetchSuccess(
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
    if (state is ParentsUserChatHistoryFetchSuccess) {
      final history =
          (state as ParentsUserChatHistoryFetchSuccess).userChatHistory;

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
        ParentsUserChatHistoryFetchSuccess(
          userChatHistory: history.copyWith(chatContacts: newContacts),
        ),
      );
    }
  }
}
