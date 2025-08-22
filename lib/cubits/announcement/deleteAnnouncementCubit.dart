import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteAnnouncementState {}

class DeleteAnnouncementInitial extends DeleteAnnouncementState {}

class DeleteAnnouncementInProgress extends DeleteAnnouncementState {}

class DeleteAnnouncementSuccess extends DeleteAnnouncementState {}

class DeleteAnnouncementFailure extends DeleteAnnouncementState {
  final String errorMessage;

  DeleteAnnouncementFailure(this.errorMessage);
}

class DeleteAnnouncementCubit extends Cubit<DeleteAnnouncementState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  DeleteAnnouncementCubit() : super(DeleteAnnouncementInitial());

  void deleteAnnouncement({required int announcementId}) async {
    try {
      emit(DeleteAnnouncementInProgress());
      await _announcementRepository.deleteAnnouncement(
          announcementId: announcementId);
      emit(DeleteAnnouncementSuccess());
    } catch (e) {
      emit(DeleteAnnouncementFailure(e.toString()));
    }
  }
}
