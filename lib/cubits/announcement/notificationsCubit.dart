import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsFetchInProgress extends NotificationsState {}

class NotificationsFetchSuccess extends NotificationsState {
  final int offset;
  final int limit;
  final bool hasMore;
  final List<NotificationDetails> notifications;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;

  NotificationsFetchSuccess({
    required this.offset,
    required this.limit,
    required this.hasMore,
    required this.notifications,
    required this.fetchMoreError,
    required this.fetchMoreInProgress,
  });

  NotificationsFetchSuccess copyWith({
    int? offset,
    int? limit,
    bool? hasMore,
    bool? fetchMoreError,
    bool? fetchMoreInProgress,
    List<NotificationDetails>? notifications,
  }) {
    return NotificationsFetchSuccess(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      notifications: notifications ?? this.notifications,
      fetchMoreError: fetchMoreError ?? this.fetchMoreError,
      fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
    );
  }
}

class NotificationsFetchFailure extends NotificationsState {
  final String errorMessage;

  NotificationsFetchFailure(this.errorMessage);
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  static const int _notificationsLimit = 10;

  NotificationsCubit() : super(NotificationsInitial());

  void getNotifications() async {
    emit(NotificationsFetchInProgress());
    try {
      final result = await _announcementRepository.getNotifications(
        offset: 0,
        limit: _notificationsLimit,
      );
      emit(NotificationsFetchSuccess(
        offset: result.offset,
        limit: result.limit,
        hasMore: result.hasMore,
        notifications: result.notifications,
        fetchMoreError: false,
        fetchMoreInProgress: false,
      ));
    } catch (e) {
      emit(NotificationsFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is NotificationsFetchSuccess) {
      final currentState = state as NotificationsFetchSuccess;
      return currentState.hasMore;
    }
    return false;
  }

  void fetchMore() async {
    if (state is NotificationsFetchSuccess) {
      final currentState = state as NotificationsFetchSuccess;

      // Prevent multiple simultaneous requests
      if (currentState.fetchMoreInProgress) {
        return;
      }

      // Check if there are more items to load
      if (!hasMore()) {
        return;
      }

      try {
        emit(currentState.copyWith(fetchMoreInProgress: true));

        final nextOffset = currentState.notifications.length;
        final result = await _announcementRepository.getNotifications(
          offset: nextOffset,
          limit: _notificationsLimit,
        );

        final updatedNotifications = List<NotificationDetails>.from(
          currentState.notifications,
        )..addAll(result.notifications);

        emit(NotificationsFetchSuccess(
          offset: nextOffset,
          limit: result.limit,
          hasMore: result.hasMore,
          notifications: updatedNotifications,
          fetchMoreError: false,
          fetchMoreInProgress: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          fetchMoreInProgress: false,
          fetchMoreError: true,
        ));
      }
    }
  }

  void retryFetchMore() {
    if (state is NotificationsFetchSuccess) {
      final currentState = state as NotificationsFetchSuccess;
      if (currentState.fetchMoreError) {
        emit(currentState.copyWith(fetchMoreError: false));
        fetchMore();
      }
    }
  }

  void deleteNotification({required int notificationId}) {
    if (state is NotificationsFetchSuccess) {
      final currentState = state as NotificationsFetchSuccess;
      final updatedNotifications = List<NotificationDetails>.from(
        currentState.notifications,
      )..removeWhere((element) => element.id == notificationId);

      emit(currentState.copyWith(
        notifications: updatedNotifications,
      ));
    }
  }

  void refresh() {
    getNotifications();
  }
}
