import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/data/repositories/diaryCategoryRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateDiaryCategoryState {}

class CreateDiaryCategoryInitial extends CreateDiaryCategoryState {}

class CreateDiaryCategoryInProgress extends CreateDiaryCategoryState {}

class CreateDiaryCategorySuccess extends CreateDiaryCategoryState {
  final DiaryCategory createdCategory;

  CreateDiaryCategorySuccess(this.createdCategory);
}

class CreateDiaryCategoryFailure extends CreateDiaryCategoryState {
  final String errorMessage;

  CreateDiaryCategoryFailure(this.errorMessage);
}

class CreateDiaryCategoryCubit extends Cubit<CreateDiaryCategoryState> {
  final DiaryCategoryRepository _diaryCategoryRepository =
      DiaryCategoryRepository();

  CreateDiaryCategoryCubit() : super(CreateDiaryCategoryInitial());

  Future<void> createDiaryCategory({
    required String name,
    required String type, // "positive" or "negative"
  }) async {
    emit(CreateDiaryCategoryInProgress());
    try {
      final createdCategory =
          await _diaryCategoryRepository.createDiaryCategory(
        name: name,
        type: type,
      );
      emit(CreateDiaryCategorySuccess(createdCategory));
    } catch (e) {
      emit(CreateDiaryCategoryFailure(e.toString()));
    }
  }
}
