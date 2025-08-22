import 'package:eschool_saas_staff/data/models/teacherAnnouncement.dart';
import 'package:eschool_saas_staff/data/repositories/teacherAnnouncementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeacherAnnouncementsState {}

class TeacherAnnouncementsInitial extends TeacherAnnouncementsState {}

class TeacherAnnouncementsFetchInProgress extends TeacherAnnouncementsState {}

class TeacherAnnouncementsFetchSuccess extends TeacherAnnouncementsState {
  final List<TeacherAnnouncement> announcements;
  final int totalPage;
  final int currentPage;
  final bool moreTeacherAnnouncementsFetchError;
  final bool fetchMoreTeacherAnnouncementsInProgress;

  TeacherAnnouncementsFetchSuccess({
    required this.announcements,
    required this.fetchMoreTeacherAnnouncementsInProgress,
    required this.moreTeacherAnnouncementsFetchError,
    required this.currentPage,
    required this.totalPage,
  });

  TeacherAnnouncementsFetchSuccess copyWith({
    List<TeacherAnnouncement>? newTeacherAnnouncements,
    bool? newFetchMoreTeacherAnnouncementsInProgress,
    bool? newMoreTeacherAnnouncementsFetchError,
    int? newCurrentPage,
    int? newTotalPage,
  }) {
    return TeacherAnnouncementsFetchSuccess(
      announcements: newTeacherAnnouncements ?? announcements,
      fetchMoreTeacherAnnouncementsInProgress:
          newFetchMoreTeacherAnnouncementsInProgress ??
              fetchMoreTeacherAnnouncementsInProgress,
      moreTeacherAnnouncementsFetchError:
          newMoreTeacherAnnouncementsFetchError ??
              moreTeacherAnnouncementsFetchError,
      currentPage: newCurrentPage ?? currentPage,
      totalPage: newTotalPage ?? totalPage,
    );
  }
}

class TeacherAnnouncementsFetchFailure extends TeacherAnnouncementsState {
  final String errorMessage;

  TeacherAnnouncementsFetchFailure({required this.errorMessage});
}

class TeacherAnnouncementsCubit extends Cubit<TeacherAnnouncementsState> {
  final TeacherAnnouncementRepository _announcementRepository =
      TeacherAnnouncementRepository();

  TeacherAnnouncementsCubit() : super(TeacherAnnouncementsInitial());

  void deleteTeacherAnnouncement({required int announcementId}) {
    if (state is TeacherAnnouncementsFetchSuccess) {
      List<TeacherAnnouncement> announcements =
          (state as TeacherAnnouncementsFetchSuccess).announcements;
      announcements.removeWhere((element) => element.id == announcementId);
      emit(
        (state as TeacherAnnouncementsFetchSuccess)
            .copyWith(newTeacherAnnouncements: announcements),
      );
    }
  }

  Future<void> fetchTeacherAnnouncements({
    required int classSectionId,
    required int classSubjectId,
  }) async {
    try {
      emit(TeacherAnnouncementsFetchInProgress());
      final result = await _announcementRepository.fetchAnnouncements(
        classSectionId: classSectionId,
        classSubjectId: classSubjectId,
      );
      emit(
        TeacherAnnouncementsFetchSuccess(
          announcements: result.announcements,
          fetchMoreTeacherAnnouncementsInProgress: false,
          moreTeacherAnnouncementsFetchError: false,
          currentPage: result.currentPage,
          totalPage: result.totalPage,
        ),
      );
    } catch (e) {
      emit(TeacherAnnouncementsFetchFailure(errorMessage: e.toString()));
    }
  }

  void updateState(TeacherAnnouncementsState updateState) {
    emit(updateState);
  }

  bool hasMore() {
    if (state is TeacherAnnouncementsFetchSuccess) {
      return (state as TeacherAnnouncementsFetchSuccess).currentPage <
          (state as TeacherAnnouncementsFetchSuccess).totalPage;
    }
    return false;
  }

  Future<void> fetchMoreTeacherAnnouncements({
    required int classSectionId,
    required int classSubjectId,
  }) async {
    if (state is TeacherAnnouncementsFetchSuccess) {
      if ((state as TeacherAnnouncementsFetchSuccess)
          .fetchMoreTeacherAnnouncementsInProgress) {
        return;
      }
      try {
        emit(
          (state as TeacherAnnouncementsFetchSuccess)
              .copyWith(newFetchMoreTeacherAnnouncementsInProgress: true),
        );
        //fetch more announcements
        //more announcements result
        final moreAssignmentsResult =
            await _announcementRepository.fetchAnnouncements(
          classSubjectId: classSubjectId,
          classSectionId: classSectionId,
          page: (state as TeacherAnnouncementsFetchSuccess).currentPage + 1,
        );

        final currentState = state as TeacherAnnouncementsFetchSuccess;
        List<TeacherAnnouncement> announcements = currentState.announcements;

        //add more announcements into original announcements list
        announcements.addAll(moreAssignmentsResult.announcements);

        emit(
          TeacherAnnouncementsFetchSuccess(
            fetchMoreTeacherAnnouncementsInProgress: false,
            announcements: announcements,
            moreTeacherAnnouncementsFetchError: false,
            currentPage: moreAssignmentsResult.currentPage,
            totalPage: moreAssignmentsResult.totalPage,
          ),
        );
      } catch (e) {
        emit(
          (state as TeacherAnnouncementsFetchSuccess).copyWith(
            newFetchMoreTeacherAnnouncementsInProgress: false,
            newMoreTeacherAnnouncementsFetchError: true,
          ),
        );
      }
    }
  }
}
