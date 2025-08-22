import 'package:eschool_saas_staff/data/repositories/lessonRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteLessonState {}

class DeleteLessonInitial extends DeleteLessonState {}

class DeleteLessonInProgress extends DeleteLessonState {}

class DeleteLessonSuccess extends DeleteLessonState {}

class DeleteLessonFailure extends DeleteLessonState {
  final String errorMessage;

  DeleteLessonFailure(this.errorMessage);
}

class DeleteLessonCubit extends Cubit<DeleteLessonState> {
  final LessonRepository _lessonRepository = LessonRepository();

  DeleteLessonCubit() : super(DeleteLessonInitial());

  Future<void> deleteLesson(int lessonId) async {
    emit(DeleteLessonInProgress());
    try {
      await _lessonRepository.deleteLesson(lessonId: lessonId);
      emit(DeleteLessonSuccess());
    } catch (e) {
      emit(DeleteLessonFailure(e.toString()));
    }
  }
}
