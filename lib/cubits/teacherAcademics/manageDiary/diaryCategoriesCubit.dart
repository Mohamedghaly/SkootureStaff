import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/data/repositories/diaryCategoryRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DiaryCategoriesState {}

class DiaryCategoriesInitial extends DiaryCategoriesState {}

class DiaryCategoriesFetchInProgress extends DiaryCategoriesState {}

class DiaryCategoriesFetchSuccess extends DiaryCategoriesState {
  final List<DiaryCategory> categories;
  final String type;

  DiaryCategoriesFetchSuccess({
    required this.categories,
    required this.type,
  });
}

class DiaryCategoriesFetchFailure extends DiaryCategoriesState {
  final String errorMessage;

  DiaryCategoriesFetchFailure({required this.errorMessage});
}

class DiaryCategoriesCubit extends Cubit<DiaryCategoriesState> {
  final DiaryCategoryRepository _diaryCategoryRepository =
      DiaryCategoryRepository();

  DiaryCategoriesCubit() : super(DiaryCategoriesInitial());

  Future<void> fetchDiaryCategories({required String type}) async {
    try {
      emit(DiaryCategoriesFetchInProgress());
      final categories =
          await _diaryCategoryRepository.getDiaryCategories(type: type);
      emit(DiaryCategoriesFetchSuccess(categories: categories, type: type));
    } catch (e) {
      emit(DiaryCategoriesFetchFailure(errorMessage: e.toString()));
    }
  }



  void updateState(DiaryCategoriesState newState) {
    emit(newState);
  }

  List<DiaryCategory> getCategories() {
    if (state is DiaryCategoriesFetchSuccess) {
      return (state as DiaryCategoriesFetchSuccess).categories;
    }
    return [];
  }
}
