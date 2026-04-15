import 'package:eschool_saas_staff/data/repositories/diaryRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateDiaryState {}

class CreateDiaryInitial extends CreateDiaryState {}

class CreateDiaryInProgress extends CreateDiaryState {}

class CreateDiarySuccess extends CreateDiaryState {
  final String message;

  CreateDiarySuccess(this.message);
}

class CreateDiaryFailure extends CreateDiaryState {
  final String errorMessage;

  CreateDiaryFailure(this.errorMessage);
}

class CreateDiaryCubit extends Cubit<CreateDiaryState> {
  final DiaryRepository _diaryRepository = DiaryRepository();

  CreateDiaryCubit() : super(CreateDiaryInitial());

  Future<void> createDiary({
    required int diaryCategoryId,
    required String date,
    required Map<int, int> studentClassSectionMap,
    int? subjectId,
    String? title,
    String? description,
  }) async {
    emit(CreateDiaryInProgress());
    try {
      final response = await _diaryRepository.createDiary(
        subjectId: subjectId,
        diaryCategoryId: diaryCategoryId,
        date: date,
        studentClassSectionMap: studentClassSectionMap,
        title: title,
        description: description,
      );

      // Debug: Print the response to see what we're getting
      debugPrint("CreateDiary API Response: $response");
      

      // Extract the message from the API response
      final message = response['message'] ?? "Diary entry created successfully";
      debugPrint("Extracted message: $message");

      emit(CreateDiarySuccess(message));
    } catch (e) {
      emit(CreateDiaryFailure(e.toString()));
    }
  }
}
