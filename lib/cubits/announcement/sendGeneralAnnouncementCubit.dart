import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SendGeneralAnnouncementState {}

class SendGeneralAnnouncementInitial extends SendGeneralAnnouncementState {}

class SendGeneralAnnouncementInProgress extends SendGeneralAnnouncementState {}

class SendGeneralAnnouncementSuccess extends SendGeneralAnnouncementState {}

class SendGeneralAnnouncementFailure extends SendGeneralAnnouncementState {
  final String errorMessage;

  SendGeneralAnnouncementFailure(this.errorMessage);
}

class SendGeneralAnnouncementCubit extends Cubit<SendGeneralAnnouncementState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  SendGeneralAnnouncementCubit() : super(SendGeneralAnnouncementInitial());

  void sendGeneralAnnouncement(
      {required String title,
      String? description,
      required List<int> classSectionIds,
      List<String>? filePaths}) async {
    try {
      emit(SendGeneralAnnouncementInProgress());
      await _announcementRepository.sendGeneralAnnouncement(
          classSectionIds: classSectionIds,
          description: description,
          filePaths: filePaths,
          title: title);
      emit(SendGeneralAnnouncementSuccess());
    } catch (e) {
      emit(SendGeneralAnnouncementFailure(e.toString()));
    }
  }
}
