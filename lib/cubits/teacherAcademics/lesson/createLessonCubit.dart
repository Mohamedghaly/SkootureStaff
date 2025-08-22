import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/repositories/lessonRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateLessonState {}

class CreateLessonInitial extends CreateLessonState {}

class CreateLessonInProgress extends CreateLessonState {}

class CreateLessonSuccess extends CreateLessonState {}

class CreateLessonFailure extends CreateLessonState {
  final String errorMessage;

  CreateLessonFailure(this.errorMessage);
}

class CreateLessonCubit extends Cubit<CreateLessonState> {
  final LessonRepository _lessonRepository = LessonRepository();

  CreateLessonCubit() : super(CreateLessonInitial());

  Future<void> createLesson({
    required String lessonName,
    required List classSectionId,
    required int classSubjectId,
    required String lessonDescription,
    required List<PickedStudyMaterial> files,
  }) async {
    emit(CreateLessonInProgress());
    try {
      List<Map<String, dynamic>> fileJson = [];
      for (var file in files) {
        fileJson.add(await file.toJson());
      }

      await _lessonRepository.createLesson(
        lessonName: lessonName,
        classSectionId: classSectionId,
        classSubjectId: classSubjectId,
        lessonDescription: lessonDescription,
        files: fileJson,
      );
      emit(CreateLessonSuccess());
    } catch (e) {
      emit(CreateLessonFailure(e.toString()));
    }
  }
}
