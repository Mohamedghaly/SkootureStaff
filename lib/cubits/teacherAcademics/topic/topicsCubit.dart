import 'package:eschool_saas_staff/data/models/topic.dart';
import 'package:eschool_saas_staff/data/repositories/topicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TopicsState {}

class TopicsInitial extends TopicsState {}

class TopicsFetchInProgress extends TopicsState {}

class TopicsFetchSuccess extends TopicsState {
  final List<Topic> topics;

  TopicsFetchSuccess(this.topics);
}

class TopicsFetchFailure extends TopicsState {
  final String errorMessage;

  TopicsFetchFailure(this.errorMessage);
}

class TopicsCubit extends Cubit<TopicsState> {
  final TopicRepository _topicRepository = TopicRepository();

  TopicsCubit() : super(TopicsInitial());

  void updateState(TopicsState updatedState) {
    emit(updatedState);
  }

  Future<void> fetchTopics({required int lessonId}) async {
    emit(TopicsFetchInProgress());
    try {
      emit(
        TopicsFetchSuccess(
          await _topicRepository.fetchTopics(lessonId: lessonId),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(TopicsFetchFailure(e.toString()));
    }
  }

  void deleteTopic(int topicId) {
    if (state is TopicsFetchSuccess) {
      List<Topic> topics = (state as TopicsFetchSuccess).topics;
      topics.removeWhere((element) => element.id == topicId);
      emit(TopicsFetchSuccess(topics));
    }
  }
}
