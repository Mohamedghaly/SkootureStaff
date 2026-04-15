import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/data/repositories/diaryCategoryRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateDiaryCategoryState {}

class UpdateDiaryCategoryInitial extends UpdateDiaryCategoryState {}

class UpdateDiaryCategoryInProgress extends UpdateDiaryCategoryState {}

class UpdateDiaryCategorySuccess extends UpdateDiaryCategoryState {
  final DiaryCategory updatedCategory;

  UpdateDiaryCategorySuccess(this.updatedCategory);
}

class UpdateDiaryCategoryFailure extends UpdateDiaryCategoryState {
  final String errorMessage;

  UpdateDiaryCategoryFailure(this.errorMessage);
}

class UpdateDiaryCategoryCubit extends Cubit<UpdateDiaryCategoryState> {
  final DiaryCategoryRepository _diaryCategoryRepository =
      DiaryCategoryRepository();

  UpdateDiaryCategoryCubit() : super(UpdateDiaryCategoryInitial());

  Future<void> updateDiaryCategory({
    required int diaryCategoryId,
    required String name,
    required String type, // "positive" or "negative"
  }) async {
    emit(UpdateDiaryCategoryInProgress());
    try {
      final updatedCategory =
          await _diaryCategoryRepository.updateDiaryCategory(
        diaryCategoryId: diaryCategoryId,
        name: name,
        type: type,
      );
      emit(UpdateDiaryCategorySuccess(updatedCategory));
    } catch (e) {
      emit(UpdateDiaryCategoryFailure(e.toString()));
    }
  }
}
