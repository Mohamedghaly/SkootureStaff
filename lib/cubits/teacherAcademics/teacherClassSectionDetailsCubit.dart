import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/repositories/teacherAcademicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeacherClassSectionDetailsState {}

class TeacherClassSectionDetailsInitial
    extends TeacherClassSectionDetailsState {}

class TeacherClassSectionDetailsFetchInProgress
    extends TeacherClassSectionDetailsState {}

class TeacherClassSectionDetailsFetchSuccess
    extends TeacherClassSectionDetailsState {
  final List<ClassSection> classSectionDetails;

  TeacherClassSectionDetailsFetchSuccess({required this.classSectionDetails});
}

class TeacherClassSectionDetailsFetchFailure
    extends TeacherClassSectionDetailsState {
  final String errorMessage;
  TeacherClassSectionDetailsFetchFailure(this.errorMessage);
}

class TeacherClassSectionDetailsCubit
    extends Cubit<TeacherClassSectionDetailsState> {
  final TeacherAcademicsRepository _teacherAcademicsRepository =
      TeacherAcademicsRepository();

  TeacherClassSectionDetailsCubit()
      : super(TeacherClassSectionDetailsInitial());

  void getTeacherClassSectionDetails({int? classId}) async {
    try {
      emit(TeacherClassSectionDetailsFetchInProgress());
      emit(TeacherClassSectionDetailsFetchSuccess(
          classSectionDetails: await _teacherAcademicsRepository
              .getClassSectionDetails(classId: classId)));
    } catch (e) {
      emit(TeacherClassSectionDetailsFetchFailure(e.toString()));
    }
  }
}
