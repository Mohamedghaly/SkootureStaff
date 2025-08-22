import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/data/repositories/teacherRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TeachersState {}

class TeachersInitial extends TeachersState {}

class TeachersFetchInProgress extends TeachersState {}

class TeachersFetchSuccess extends TeachersState {
  List<UserDetails> teachers;

  TeachersFetchSuccess({required this.teachers});
}

class TeachersFetchFailure extends TeachersState {
  final String errorMessage;

  TeachersFetchFailure(this.errorMessage);
}

class TeachersCubit extends Cubit<TeachersState> {
  final TeacherRepository _teacherRepository = TeacherRepository();

  TeachersCubit() : super(TeachersInitial());

  void getTeachers({String? search}) async {
    try {
      emit(TeachersFetchInProgress());
      emit(TeachersFetchSuccess(
          teachers: await _teacherRepository.getTeachers(search: search)));
    } catch (e) {
      emit(TeachersFetchFailure(e.toString()));
    }
  }
}
