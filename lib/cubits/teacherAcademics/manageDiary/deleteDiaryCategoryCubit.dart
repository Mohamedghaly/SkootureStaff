import 'package:eschool_saas_staff/data/repositories/diaryCategoryRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteDiaryCategoryState {}

class DeleteDiaryCategoryInitial extends DeleteDiaryCategoryState {}

class DeleteDiaryCategoryInProgress extends DeleteDiaryCategoryState {}

class DeleteDiaryCategorySuccess extends DeleteDiaryCategoryState {}

class DeleteDiaryCategoryFailure extends DeleteDiaryCategoryState {
  final String errorMessage;

  DeleteDiaryCategoryFailure(this.errorMessage);
}

class DeleteDiaryCategoryCubit extends Cubit<DeleteDiaryCategoryState> {
  final DiaryCategoryRepository _diaryCategoryRepository =
      DiaryCategoryRepository();

  DeleteDiaryCategoryCubit() : super(DeleteDiaryCategoryInitial());

  Future<void> deleteDiaryCategory({
    required int diaryCategoryId,
  }) async {
    emit(DeleteDiaryCategoryInProgress());
    try {
      await _diaryCategoryRepository.deleteDiaryCategory(
        diaryCategoryId: diaryCategoryId,
      );
      emit(DeleteDiaryCategorySuccess());
    } catch (e) {
      emit(DeleteDiaryCategoryFailure(e.toString()));
    }
  }
}
