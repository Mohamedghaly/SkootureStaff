import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/repositories/lessonRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EditLessonState {}

class EditLessonInitial extends EditLessonState {}

class EditLessonInProgress extends EditLessonState {}

class EditLessonSuccess extends EditLessonState {}

class EditLessonFailure extends EditLessonState {
  final String errorMessage;

  EditLessonFailure(this.errorMessage);
}

class EditLessonCubit extends Cubit<EditLessonState> {
  final LessonRepository _lessonRepository = LessonRepository();

  EditLessonCubit() : super(EditLessonInitial());

  Future<void> editLesson({
    required String lessonName,
    required int lessonId,
    required List<int> classSectionId,
    required int classSubjectId,
    required String lessonDescription,
    required List<PickedStudyMaterial> files,
  }) async {
    emit(EditLessonInProgress());
    try {
      List<Map<String, dynamic>> fileJson = [];
      for (var file in files) {
        fileJson.add(await file.toJson());
      }

      await _lessonRepository.updateLesson(
        lessonId: lessonId,
        lessonName: lessonName,
        classSectionId: classSectionId,
        classSubjectId: classSubjectId,
        lessonDescription: lessonDescription,
        files: fileJson,
      );
      emit(EditLessonSuccess());
    } catch (e) {

      emit(EditLessonFailure(e.toString()));
    }
  }
}
