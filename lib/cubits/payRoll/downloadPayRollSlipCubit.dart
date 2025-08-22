import 'dart:convert';
import 'dart:io';

import 'package:eschool_saas_staff/data/repositories/payRollRepository.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

abstract class DownloadPayRollSlipState {}

class DownloadPayRollSlipInitial extends DownloadPayRollSlipState {}

class DownloadPayRollSlipInProgress extends DownloadPayRollSlipState {}

class DownloadPayRollSlipSuccess extends DownloadPayRollSlipState {
  final String downloadedFilePath;

  DownloadPayRollSlipSuccess({required this.downloadedFilePath});
}

class DownloadPayRollSlipFailure extends DownloadPayRollSlipState {
  final String errorMessage;

  DownloadPayRollSlipFailure(this.errorMessage);
}

class DownloadPayRollSlipCubit extends Cubit<DownloadPayRollSlipState> {
  final PayRollRepository _payRollRepository = PayRollRepository();

  DownloadPayRollSlipCubit() : super(DownloadPayRollSlipInitial());

  void downloadPayRollSlip(
      {required int payRollId, required String payRollSlipTitle}) async {
    try {
      emit(DownloadPayRollSlipInProgress());

      String filePath = "";
      final path = (await getApplicationDocumentsDirectory()).path;
      filePath = "$path/Salary-Slips/$payRollSlipTitle-$payRollId.pdf";

      final File file = File(filePath);

      final slipContent =
          await _payRollRepository.downloadPayRollSlip(payRollId: payRollId);

      await file.create(recursive: true);
      await file.writeAsBytes(base64Decode(slipContent));
      emit(DownloadPayRollSlipSuccess(downloadedFilePath: filePath));
    } catch (e) {
      emit(DownloadPayRollSlipFailure(defaultErrorMessageKey));
    }
  }
}
