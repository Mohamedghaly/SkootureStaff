import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// DEPRECATED: This cubit is no longer used. Use NotificationsCubit instead which fetches from API.
// This file is kept for backward compatibility but will be removed in future versions.
// All references to LocalNotificationsCubit have been replaced with NotificationsCubit.

abstract class LocalNotificationsState {}

class LocalNotificationsInitial extends LocalNotificationsState {}

class LocalNotificationsFetchInProgress extends LocalNotificationsState {}

class LocalNotificationsFetchSuccess extends LocalNotificationsState {
  final List<NotificationDetails> notifications;

  LocalNotificationsFetchSuccess({required this.notifications});
}

class LocalNotificationsFetchFailure extends LocalNotificationsState {
  final String errorMessage;

  LocalNotificationsFetchFailure(this.errorMessage);
}

class LocalNotificationsCubit extends Cubit<LocalNotificationsState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  LocalNotificationsCubit() : super(LocalNotificationsInitial());

  // DEPRECATED: Use NotificationsCubit.getNotifications() instead
  void getLocalNotifications() async {
    try {
      emit(LocalNotificationsFetchInProgress());

      // Fetch from API instead of local storage
      final result = await _announcementRepository.getNotifications();

      emit(LocalNotificationsFetchSuccess(
          notifications: result.notifications));
    } catch (e) {
      emit(LocalNotificationsFetchFailure(e.toString()));
    }
  }
}
