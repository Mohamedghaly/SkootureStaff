import 'dart:io';

import 'package:eschool_saas_staff/data/repositories/staffRepository.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

abstract class DownloadStaffIdCardState {}

class DownloadStaffIdCardInitial extends DownloadStaffIdCardState {}

class DownloadStaffIdCardInProgress extends DownloadStaffIdCardState {}

class DownloadStaffIdCardSuccess extends DownloadStaffIdCardState {
  final String downloadedFilePath;

  DownloadStaffIdCardSuccess({required this.downloadedFilePath});
}

class DownloadStaffIdCardFailure extends DownloadStaffIdCardState {
  final String errorMessage;

  DownloadStaffIdCardFailure(this.errorMessage);
}

class DownloadStaffIdCardCubit extends Cubit<DownloadStaffIdCardState> {
  final StaffRepository _staffRepository = StaffRepository();

  DownloadStaffIdCardCubit() : super(DownloadStaffIdCardInitial());

  void downloadStaffIdCard() async {
    try {
      emit(DownloadStaffIdCardInProgress());

      final path = (await getApplicationDocumentsDirectory()).path;
      const String fileName = "staff-id-card.pdf";
      final String filePath = "$path/IdCards/$fileName";

      final File file = File(filePath);

      /// Repository returns decoded Uint8List bytes directly.
      final pdfBytes = await _staffRepository.downloadIdCard();

      await file.create(recursive: true);
      await file.writeAsBytes(pdfBytes);

      emit(DownloadStaffIdCardSuccess(downloadedFilePath: filePath));
    } on ApiException catch (e) {
      emit(DownloadStaffIdCardFailure(e.errorMessage));
    } catch (_) {
      emit(DownloadStaffIdCardFailure(defaultErrorMessageKey));
    }
  }
}
