import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void getLocalNotifications() async {
    try {
      emit(LocalNotificationsFetchInProgress());

      emit(LocalNotificationsFetchSuccess(
          notifications:
              await _announcementRepository.getLocalNotifications()));
    } catch (e) {
      emit(LocalNotificationsFetchFailure(e.toString()));
    }
  }
}
