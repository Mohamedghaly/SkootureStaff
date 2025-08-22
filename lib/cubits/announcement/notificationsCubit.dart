import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsFetchInProgress extends NotificationsState {}

class NotificationsFetchSuccess extends NotificationsState {
  final int totalPage;
  final int currentPage;
  final List<NotificationDetails> notifications;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;

  NotificationsFetchSuccess(
      {required this.currentPage,
      required this.notifications,
      required this.fetchMoreError,
      required this.fetchMoreInProgress,
      required this.totalPage});

  NotificationsFetchSuccess copyWith(
      {int? currentPage,
      bool? fetchMoreError,
      bool? fetchMoreInProgress,
      int? totalPage,
      List<NotificationDetails>? notifications}) {
    return NotificationsFetchSuccess(
        currentPage: currentPage ?? this.currentPage,
        notifications: notifications ?? this.notifications,
        fetchMoreError: fetchMoreError ?? this.fetchMoreError,
        fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
        totalPage: totalPage ?? this.totalPage);
  }
}

class NotificationsFetchFailure extends NotificationsState {
  final String errorMessage;

  NotificationsFetchFailure(this.errorMessage);
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  NotificationsCubit() : super(NotificationsInitial());

  void getNotifications() async {
    emit(NotificationsFetchInProgress());
    try {
      final result = await _announcementRepository.getNotifications();
      emit(NotificationsFetchSuccess(
          currentPage: result.currentPage,
          notifications: result.notifications,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          totalPage: result.totalPage));
    } catch (e) {
      emit(NotificationsFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is NotificationsFetchSuccess) {
      return (state as NotificationsFetchSuccess).currentPage <
          (state as NotificationsFetchSuccess).totalPage;
    }
    return false;
  }

  void fetchMore() async {
    //
    if (state is NotificationsFetchSuccess) {
      if ((state as NotificationsFetchSuccess).fetchMoreInProgress) {
        return;
      }
      try {
        emit((state as NotificationsFetchSuccess)
            .copyWith(fetchMoreInProgress: true));

        final result = await _announcementRepository.getNotifications(
            page: (state as NotificationsFetchSuccess).currentPage + 1);

        final currentState = (state as NotificationsFetchSuccess);
        List<NotificationDetails> notifications = currentState.notifications;

        notifications.addAll(result.notifications);

        emit(NotificationsFetchSuccess(
            currentPage: result.currentPage,
            fetchMoreError: false,
            fetchMoreInProgress: false,
            totalPage: result.totalPage,
            notifications: notifications));
      } catch (e) {
        emit((state as NotificationsFetchSuccess)
            .copyWith(fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }

  void deleteNotification({required int notificationId}) {
    if (state is NotificationsFetchSuccess) {
      List<NotificationDetails> notifications =
          (state as NotificationsFetchSuccess).notifications;
      notifications.removeWhere((element) => element.id == notificationId);

      emit((state as NotificationsFetchSuccess)
          .copyWith(notifications: notifications));
    }
  }
}
