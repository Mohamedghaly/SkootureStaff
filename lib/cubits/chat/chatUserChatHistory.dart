import 'package:eschool_saas_staff/data/models/models.dart';
import 'package:eschool_saas_staff/data/repositories/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserChatHistoryState {}

class UserChatHistoryInitial extends UserChatHistoryState {}

class UserChatHistoryFetchInProgress extends UserChatHistoryState {}

class UserChatHistoryFetchSuccess extends UserChatHistoryState {
  final UserChatHistory userChatHistory;
  final bool loadMore;

  UserChatHistoryFetchSuccess({
    required this.userChatHistory,
    this.loadMore = false,
  });
}

class UserChatHistoryFetchFailure extends UserChatHistoryState {
  final String errorMessage;

  UserChatHistoryFetchFailure(this.errorMessage);
}

class UserChatHistoryCubit extends Cubit<UserChatHistoryState> {
  UserChatHistoryCubit() : super(UserChatHistoryInitial());

  final ChatRepository _chatRepository = ChatRepository();

  void fetchUserChatHistory({required ChatUserRole role, int page = 1}) async {
    emit(UserChatHistoryFetchInProgress());

    await _chatRepository
        .getUserChatHistory(role: role, page: page)
        .then(
          (userChatHistory) => emit(
            UserChatHistoryFetchSuccess(userChatHistory: userChatHistory),
          ),
        )
        .catchError(
          (Object e) => emit(UserChatHistoryFetchFailure(e.toString())),
        );
  }

  bool get hasMore {
    if (state is UserChatHistoryFetchSuccess) {
      final history = (state as UserChatHistoryFetchSuccess).userChatHistory;

      return history.currentPage < history.lastPage;
    } else {
      return false;
    }
  }

  void fetchMoreUserChatHistory({required ChatUserRole role}) async {
    if (state is UserChatHistoryFetchSuccess &&
        !(state as UserChatHistoryFetchSuccess).loadMore) {
      final oldHistory = (state as UserChatHistoryFetchSuccess).userChatHistory;

      emit(UserChatHistoryFetchSuccess(
        userChatHistory: oldHistory,
        loadMore: true,
      ));

      await _chatRepository
          .getUserChatHistory(
        role: role,
        page: oldHistory.currentPage + 1,
      )
          .then(
        (userChatHistory) {
          final newContacts = oldHistory.chatContacts
            ..addAll(userChatHistory.chatContacts);

          emit(
            UserChatHistoryFetchSuccess(
              userChatHistory:
                  userChatHistory.copyWith(chatContacts: newContacts),
              loadMore: false,
            ),
          );
        },
      ).catchError(
        (Object e) {
          emit(UserChatHistoryFetchFailure(e.toString()));
        },
      );
    }
  }
}
