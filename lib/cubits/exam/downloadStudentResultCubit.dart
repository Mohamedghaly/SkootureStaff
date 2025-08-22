import 'dart:convert';
import 'dart:io';

import 'package:eschool_saas_staff/data/repositories/examRepository.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

abstract class DownloadStudentResultState {}

class DownloadStudentResultInitial extends DownloadStudentResultState {}

class DownloadStudentResultInProgress extends DownloadStudentResultState {}

class DownloadStudentResultSuccess extends DownloadStudentResultState {
  final String downloadedFilePath;

  DownloadStudentResultSuccess({required this.downloadedFilePath});
}

class DownloadStudentResultFailure extends DownloadStudentResultState {
  final String errorMessage;

  DownloadStudentResultFailure(this.errorMessage);
}

class DownloadStudentResultCubit extends Cubit<DownloadStudentResultState> {
  final ExamRepository _examRepository = ExamRepository();

  DownloadStudentResultCubit() : super(DownloadStudentResultInitial());

  void downloadStudentResult(
      {required int childId, required int examId}) async {
    try {
      emit(DownloadStudentResultInProgress());

      String filePath = "";
      final path = (await getApplicationDocumentsDirectory()).path;
      filePath = "$path/Results/$childId-$examId.pdf";

      final File file = File(filePath);

      final receiptContent = await _examRepository.downloadResult(
          studentId: childId, examId: examId);
      await file.create(recursive: true);

      await file.writeAsBytes(base64Decode(receiptContent));
      emit(DownloadStudentResultSuccess(downloadedFilePath: filePath));
    } catch (e) {
      emit(DownloadStudentResultFailure(defaultErrorMessageKey));
    }
  }
}
