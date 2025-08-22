import 'package:eschool_saas_staff/data/models/announcement.dart';
import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AnnouncementsState {}

class AnnouncementsInitial extends AnnouncementsState {}

class AnnouncementsFetchInProgress extends AnnouncementsState {}

class AnnouncementsFetchSuccess extends AnnouncementsState {
  final int totalPage;
  final int currentPage;
  final List<Announcement> announcements;

  final bool fetchMoreError;
  final bool fetchMoreInProgress;

  AnnouncementsFetchSuccess(
      {required this.currentPage,
      required this.announcements,
      required this.fetchMoreError,
      required this.fetchMoreInProgress,
      required this.totalPage});

  AnnouncementsFetchSuccess copyWith(
      {int? currentPage,
      bool? fetchMoreError,
      bool? fetchMoreInProgress,
      int? totalPage,
      List<Announcement>? announcements}) {
    return AnnouncementsFetchSuccess(
        currentPage: currentPage ?? this.currentPage,
        announcements: announcements ?? this.announcements,
        fetchMoreError: fetchMoreError ?? this.fetchMoreError,
        fetchMoreInProgress: fetchMoreInProgress ?? this.fetchMoreInProgress,
        totalPage: totalPage ?? this.totalPage);
  }
}

class AnnouncementsFetchFailure extends AnnouncementsState {
  final String errorMessage;

  AnnouncementsFetchFailure(this.errorMessage);
}

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final AnnouncementRepository _announcementRepository =
      AnnouncementRepository();

  AnnouncementsCubit() : super(AnnouncementsInitial());

  void getAnnouncements({required List<int> classSectionId}) async {
    emit(AnnouncementsFetchInProgress());
    try {
      final result = await _announcementRepository.getAnnouncements(
        classSectionIds: classSectionId,
      );
      emit(AnnouncementsFetchSuccess(
          currentPage: result.currentPage,
          announcements: result.announcements,
          fetchMoreError: false,
          fetchMoreInProgress: false,
          totalPage: result.totalPage));
    } catch (e) {

      emit(AnnouncementsFetchFailure(e.toString()));
    }
  }

  bool hasMore() {
    if (state is AnnouncementsFetchSuccess) {
      return (state as AnnouncementsFetchSuccess).currentPage <
          (state as AnnouncementsFetchSuccess).totalPage;
    }
    return false;
  }

  void fetchMore({required List<int>  classSectionId}) async {
    if (state is AnnouncementsFetchSuccess) {
      final currentState = (state as AnnouncementsFetchSuccess);

      if (currentState.fetchMoreInProgress) {
        return;
      }

      try {
        emit(currentState.copyWith(fetchMoreInProgress: true));

        final result = await _announcementRepository.getAnnouncements(
          classSectionIds: classSectionId,
          page: currentState.currentPage + 1,
        );

        final List<Announcement> updatedAnnouncements =
            List.from(currentState.announcements)..addAll(result.announcements);

        emit(AnnouncementsFetchSuccess(
          currentPage: result.currentPage,
          totalPage: result.totalPage,
          announcements: updatedAnnouncements,
          fetchMoreInProgress: false,
          fetchMoreError: false,
        ));
      } catch (e) {
  
        emit(currentState.copyWith(
            fetchMoreInProgress: false, fetchMoreError: true));
      }
    }
  }

  void deleteAnnouncement({required int announcementId}) {
    if (state is AnnouncementsFetchSuccess) {
      final announcements = (state as AnnouncementsFetchSuccess).announcements;
      announcements.removeWhere((element) => element.id == announcementId);
      emit((state as AnnouncementsFetchSuccess)
          .copyWith(announcements: announcements));
    }
  }
}
