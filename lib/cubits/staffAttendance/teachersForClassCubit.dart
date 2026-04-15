import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/data/repositories/staffAttendanceRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeachersForClassState {}

class TeachersForClassInitial extends TeachersForClassState {}

class TeachersForClassFetchInProgress extends TeachersForClassState {}

class TeachersForClassFetchSuccess extends TeachersForClassState {
  final List<StaffMember> teachers;

  TeachersForClassFetchSuccess({required this.teachers});
}

class TeachersForClassFetchFailure extends TeachersForClassState {
  final String errorMessage;

  TeachersForClassFetchFailure(this.errorMessage);
}

class TeachersForClassCubit extends Cubit<TeachersForClassState> {
  final StaffAttendanceRepository _repository = StaffAttendanceRepository();

  TeachersForClassCubit() : super(TeachersForClassInitial());

  Future<void> fetchTeachersForClass({required int classSectionId}) async {
    emit(TeachersForClassFetchInProgress());
    try {
      final teachers =
          await _repository.getTeachersForClass(classSectionId: classSectionId);
      emit(TeachersForClassFetchSuccess(teachers: teachers));
    } catch (e) {
      emit(TeachersForClassFetchFailure(e.toString()));
    }
  }

  List<StaffMember> getTeachers() {
    if (state is TeachersForClassFetchSuccess) {
      return (state as TeachersForClassFetchSuccess).teachers;
    }
    return [];
  }
}
