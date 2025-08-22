import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteNotificationState {}

class DeleteNotificationInitial extends DeleteNotificationState {}

class DeleteNotificationInProgress extends DeleteNotificationState {}

class DeleteNotificationSuccess extends DeleteNotificationState {}

class DeleteNotificationFailure extends DeleteNotificationState {
  final String errorMessage;

  DeleteNotificationFailure(this.errorMessage);
}

class DeleteNotificationCubit extends Cubit<DeleteNotificationState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  DeleteNotificationCubit() : super(DeleteNotificationInitial());

  void deleteNotification({required int notificationId}) async {
    try {
      emit(DeleteNotificationInProgress());

      await _announcementRepository.deleteNotification(
          notificationId: notificationId);
      emit(DeleteNotificationSuccess());
    } catch (e) {
      emit(DeleteNotificationFailure(e.toString()));
    }
  }
}
