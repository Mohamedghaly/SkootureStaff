import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EditGeneralAnnouncementState {}

class EditGeneralAnnouncementInitial extends EditGeneralAnnouncementState {}

class EditGeneralAnnouncementInProgress extends EditGeneralAnnouncementState {}

class EditGeneralAnnouncementSuccess extends EditGeneralAnnouncementState {}

class EditGeneralAnnouncementFailure extends EditGeneralAnnouncementState {
  final String errorMessage;

  EditGeneralAnnouncementFailure(this.errorMessage);
}

class EditGeneralAnnouncementCubit extends Cubit<EditGeneralAnnouncementState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  EditGeneralAnnouncementCubit() : super(EditGeneralAnnouncementInitial());

  void editGeneralAnnouncement(
      {required int announcementId,
      required String title,
      String? description,
      required List<int> classSectionIds,
      List<String>? filePaths}) async {
    try {
      emit(EditGeneralAnnouncementInProgress());
      await _announcementRepository.editGeneralAnnouncement(
          announcementId: announcementId,
          classSectionIds: classSectionIds,
          title: title,
          description: description,
          filePaths: filePaths);

      emit(EditGeneralAnnouncementSuccess());
    } catch (e) {
      emit(EditGeneralAnnouncementFailure(e.toString()));
    }
  }
}
