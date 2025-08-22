import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SendNotificationState {}

class SendNotificationInitial extends SendNotificationState {}

class SendNotificationInProgress extends SendNotificationState {}

class SendNotificationSuccess extends SendNotificationState {}

class SendNotificationFailure extends SendNotificationState {
  final String errorMessage;

  SendNotificationFailure(this.errorMessage);
}

class SendNotificationCubit extends Cubit<SendNotificationState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  SendNotificationCubit() : super(SendNotificationInitial());

  void sendNotification(
      {required String title,
      required String message,
      required String sendToType,
      List<String>? roles,
      List<int>? userIds,
      String? filePath}) async {
    try {
      emit(SendNotificationInProgress());

      String sendTo = allUserSendNotificationTypeKey;

      if (sendToType == overDueFeesKey) {
        sendTo = overDueFeesNotificationTypeKey;
      } else if (sendToType == specificRolesKey) {
        sendTo = specificRolesSendNotificationTypeKey;
      } else if (sendToType == specificUsersKey) {
        sendTo = specificUserSendNotificationTypeKey;
      }

      await _announcementRepository.sendNotification(
          userIds: userIds,
          title: title,
          roles: roles,
          message: message,
          sendTo: sendTo,
          filePath: filePath);
      emit(SendNotificationSuccess());
    } catch (e) {
      emit(SendNotificationFailure(e.toString()));
    }
  }
}
