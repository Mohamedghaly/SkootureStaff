import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/repositories/topicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EditTopicState {}

class EditTopicInitial extends EditTopicState {}

class EditTopicInProgress extends EditTopicState {}

class EditTopicSuccess extends EditTopicState {}

class EditTopicFailure extends EditTopicState {
  final String errorMessage;

  EditTopicFailure(this.errorMessage);
}

class EditTopicCubit extends Cubit<EditTopicState> {
  final TopicRepository _topicRepository = TopicRepository();

  EditTopicCubit() : super(EditTopicInitial());

  Future<void> editTopic({
    required String topicName,
    required int lessonId,
    required List classSectionId,
    required int subjectId,
    required String topicDescription,
    required int topicId,
    required List<PickedStudyMaterial> files,
  }) async {
    emit(EditTopicInProgress());
    try {
      List<Map<String, dynamic>> filesJosn = [];
      for (var file in files) {
        filesJosn.add(await file.toJson());
      }
      
      await _topicRepository.editTopic(
        topicId: topicId,
        topicName: topicName,
        classSectionId: classSectionId,
        subjectId: subjectId,
        topicDescription: topicDescription,
        lessonId: lessonId,
        files: filesJosn,
      );

      emit(EditTopicSuccess());
    } catch (e) {
      emit(EditTopicFailure(e.toString()));
    }
  }
}
