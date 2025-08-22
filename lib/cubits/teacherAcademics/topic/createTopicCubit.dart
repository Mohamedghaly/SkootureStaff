import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/repositories/topicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateTopicState {}

class CreateTopicInitial extends CreateTopicState {}

class CreateTopicInProgress extends CreateTopicState {}

class CreateTopicSuccess extends CreateTopicState {}

class CreateTopicFailure extends CreateTopicState {
  final String errorMessage;

  CreateTopicFailure(this.errorMessage);
}

class CreateTopicCubit extends Cubit<CreateTopicState> {
  final TopicRepository _topicRepository = TopicRepository();

  CreateTopicCubit() : super(CreateTopicInitial());

  Future<void> createTopic({
    required String topicName,
    required int lessonId,
    required List classSectionId,
    required int subjectId,
    required String topicDescription,
    required List<PickedStudyMaterial> files,
  }) async {
    emit(CreateTopicInProgress());
    try {
      List<Map<String, dynamic>> filesJson = [];
      for (var file in files) {
        filesJson.add(await file.toJson());
      }
      await _topicRepository.createTopic(
        topicName: topicName,
        classSectionId: classSectionId,
        subjectId: subjectId,
        topicDescription: topicDescription,
        lessonId: lessonId,
        files: filesJson,
      );
      emit(CreateTopicSuccess());
    } catch (e) {
      emit(CreateTopicFailure(e.toString()));
    }
  }
}
