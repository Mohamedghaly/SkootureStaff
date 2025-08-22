import 'package:eschool_saas_staff/data/repositories/teacherAnnouncementRepository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeacherCreateAnnouncementState {}

class TeacherCreateAnnouncementInitial extends TeacherCreateAnnouncementState {}

class TeacherCreateAnnouncementInProgress
    extends TeacherCreateAnnouncementState {}

class TeacherCreateAnnouncementSuccess extends TeacherCreateAnnouncementState {}

class TeacherCreateAnnouncementFailure extends TeacherCreateAnnouncementState {
  final String errorMessage;

  TeacherCreateAnnouncementFailure(this.errorMessage);
}

class TeacherCreateAnnouncementCubit
    extends Cubit<TeacherCreateAnnouncementState> {
  final TeacherAnnouncementRepository _announcementRepository =
      TeacherAnnouncementRepository();

  TeacherCreateAnnouncementCubit() : super(TeacherCreateAnnouncementInitial());

  Future<void> createAnnouncement(
      {required String title,
      required String description,
      required List<PlatformFile> attachments,
      required List<int> classSectionId,
      required int classSubjectId,
      required String url}) async {
    emit(TeacherCreateAnnouncementInProgress());
    try {
      await _announcementRepository.createAnnouncement(
        url: url,
        title: title,
        description: description,
        attachments: attachments,
        classSectionId: classSectionId,
        classSubjectId: classSubjectId,
      );
      emit(TeacherCreateAnnouncementSuccess());
    } catch (e) {
      emit(TeacherCreateAnnouncementFailure(e.toString()));
    }
  }
}
