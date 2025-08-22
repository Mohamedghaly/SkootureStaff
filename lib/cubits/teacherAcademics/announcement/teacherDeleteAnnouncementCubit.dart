import 'package:eschool_saas_staff/data/repositories/teacherAnnouncementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeacherDeleteAnnouncementState {}

class TeacherDeleteAnnouncementInitial extends TeacherDeleteAnnouncementState {}

class TeacherDeleteAnnouncementInProgress
    extends TeacherDeleteAnnouncementState {}

class TeacherDeleteAnnouncementSuccess extends TeacherDeleteAnnouncementState {}

class TeacherDeleteAnnouncementFailure extends TeacherDeleteAnnouncementState {
  final String errorMessage;

  TeacherDeleteAnnouncementFailure(this.errorMessage);
}

class TeacherDeleteAnnouncementCubit
    extends Cubit<TeacherDeleteAnnouncementState> {
  final TeacherAnnouncementRepository _announcementRepository =
      TeacherAnnouncementRepository();

  TeacherDeleteAnnouncementCubit() : super(TeacherDeleteAnnouncementInitial());

  Future<void> deleteAnnouncement({required int announcementId}) async {
    emit(TeacherDeleteAnnouncementInProgress());
    try {
      await _announcementRepository.deleteAnnouncement(announcementId);
      emit(TeacherDeleteAnnouncementSuccess());
    } catch (e) {
      emit(TeacherDeleteAnnouncementFailure(state.toString()));
    }
  }
}
