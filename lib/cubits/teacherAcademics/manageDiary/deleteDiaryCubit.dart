import 'package:eschool_saas_staff/data/repositories/diaryRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteDiaryState {}

class DeleteDiaryInitial extends DeleteDiaryState {}

class DeleteDiaryInProgress extends DeleteDiaryState {}

class DeleteDiarySuccess extends DeleteDiaryState {}

class DeleteDiaryFailure extends DeleteDiaryState {
  final String errorMessage;

  DeleteDiaryFailure(this.errorMessage);
}

class DeleteDiaryCubit extends Cubit<DeleteDiaryState> {
  final DiaryRepository _diaryRepository = DiaryRepository();

  DeleteDiaryCubit() : super(DeleteDiaryInitial());

  Future<void> deleteDiary({
    required int diaryId,
  }) async {
    emit(DeleteDiaryInProgress());
    try {
      await _diaryRepository.deleteDiary(
        diaryId: diaryId,
      );
      emit(DeleteDiarySuccess());
    } catch (e) {
      emit(DeleteDiaryFailure(e.toString()));
    }
  }
}
