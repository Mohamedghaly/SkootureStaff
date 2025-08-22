import 'package:eschool_saas_staff/data/models/models.dart';
import 'package:eschool_saas_staff/data/repositories/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StudentsUserChatHistoryState {}

class StudentsUserChatHistoryInitial extends StudentsUserChatHistoryState {}

class StudentsUserChatHistoryFetchInProgress
    extends StudentsUserChatHistoryState {}

class StudentsUserChatHistoryFetchSuccess extends StudentsUserChatHistoryState {
  final UserChatHistory userChatHistory;
  final bool loadMore;

  StudentsUserChatHistoryFetchSuccess({
    required this.userChatHistory,
    this.loadMore = false,
  });
}

class StudentsUserChatHistoryFetchFailure extends StudentsUserChatHistoryState {
  final String errorMessage;

  StudentsUserChatHistoryFetchFailure(this.errorMessage);
}

class StudentsUserChatHistoryCubit extends Cubit<StudentsUserChatHistoryState> {
  StudentsUserChatHistoryCubit() : super(StudentsUserChatHistoryInitial());

  final ChatRepository _chatRepository = ChatRepository();

  void fetchUserChatHistory({int page = 1}) async {
    emit(StudentsUserChatHistoryFetchInProgress());

    await _chatRepository
        .getUserChatHistory(role: ChatUserRole.student, page: page)
        .then(
          (userChatHistory) => emit(
            StudentsUserChatHistoryFetchSuccess(
                userChatHistory: userChatHistory),
          ),
        )
        .catchError(
      (Object e) {
        if (isClosed) return;
        emit(StudentsUserChatHistoryFetchFailure(e.toString()));
      },
    );
  }

  bool get hasMore {
    if (state is StudentsUserChatHistoryFetchSuccess) {
      final history =
          (state as StudentsUserChatHistoryFetchSuccess).userChatHistory;

      return history.currentPage < history.lastPage;
    } else {
      return false;
    }
  }

  void fetchMoreUserChatHistory() async {
    if (state is StudentsUserChatHistoryFetchSuccess &&
        !(state as StudentsUserChatHistoryFetchSuccess).loadMore) {
      final oldHistory =
          (state as StudentsUserChatHistoryFetchSuccess).userChatHistory;

      emit(StudentsUserChatHistoryFetchSuccess(
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
            StudentsUserChatHistoryFetchSuccess(
              userChatHistory:
                  userChatHistory.copyWith(chatContacts: newContacts),
              loadMore: false,
            ),
          );
        },
      ).catchError(
        (Object e) {
          emit(StudentsUserChatHistoryFetchFailure(e.toString()));
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
    if (state is StudentsUserChatHistoryFetchSuccess) {
      final history =
          (state as StudentsUserChatHistoryFetchSuccess).userChatHistory;

      final chatContact = history.chatContacts
          .where((e) => e.user.id.toString() == from)
          .firstOrNull;

      /// message received from a chat contact that is not in the history
      if (chatContact == null) return;

      final updatedContact = chatContact.copyWith(
        lastMessage: message,
        updatedAt: updatedAt,
        unreadCount: incrementUnreadCount ? chatContact.unreadCount + 1 : null,
      );

      final newContacts = history.chatContacts
          .map((e) => e.user.id.toString() == from ? e = updatedContact : e)
          .toList();

      emit(
        StudentsUserChatHistoryFetchSuccess(
          userChatHistory: history.copyWith(chatContacts: newContacts),
        ),
      );
    }
  }

  void updateUnreadCount(int receiverId, int count) {
    if (state is StudentsUserChatHistoryFetchSuccess) {
      final history =
          (state as StudentsUserChatHistoryFetchSuccess).userChatHistory;

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
        StudentsUserChatHistoryFetchSuccess(
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
    if (state is StudentsUserChatHistoryFetchSuccess) {
      final history =
          (state as StudentsUserChatHistoryFetchSuccess).userChatHistory;

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
        StudentsUserChatHistoryFetchSuccess(
          userChatHistory: history.copyWith(chatContacts: newContacts),
        ),
      );
    }
  }
}
