import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/repositories/studyMaterialRepository.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class DownloadFileState {}

class DownloadFileInitial extends DownloadFileState {}

class DownloadFileInProgress extends DownloadFileState {
  final double uploadedPercentage;

  DownloadFileInProgress(this.uploadedPercentage);
}

class DownloadFileSuccess extends DownloadFileState {
  final String downloadedFileUrl;

  DownloadFileSuccess(this.downloadedFileUrl);
}

class DownloadFileProcessCanceled extends DownloadFileState {}

class DownloadFileFailure extends DownloadFileState {
  final String errorMessage;

  DownloadFileFailure(
    this.errorMessage,
  );
}

class DownloadFileCubit extends Cubit<DownloadFileState> {
  final StudyMaterialRepository _studyMaterialRepository =
      StudyMaterialRepository();

  DownloadFileCubit() : super(DownloadFileInitial());

  final CancelToken _cancelToken = CancelToken();

  void _downloadedFilePercentage(double percentage) {
    emit(DownloadFileInProgress(percentage));
  }

  Future<void> writeFileFromTempStorage({
    required String sourcePath,
    required String destinationPath,
  }) async {
    final tempFile = File(sourcePath);
    final byteData = await tempFile.readAsBytes();
    final downloadedFile = File(destinationPath);
    //write into downloaded file
    await downloadedFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
  }

  Future<void> downloadFile({
    required StudyMaterial studyMaterial,
  }) async {
    emit(DownloadFileInProgress(0.0));
    try {
      //if wants to download the file then
      Future<void> thingsToDoAfterPermissionIsGiven(
          bool isPermissionGranted) async {
        //storing the fie temp
        final Directory tempDir = await getTemporaryDirectory();
        final tempFileSavePath =
            "${tempDir.path}/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

        //if same name file is already there, just open it by emitting success
        if (await File(tempFileSavePath).exists()) {
          emit(DownloadFileSuccess(tempFileSavePath));
          return;
        }

        await _studyMaterialRepository.downloadStudyMaterialFile(
          cancelToken: _cancelToken,
          savePath: tempFileSavePath,
          updateDownloadedPercentage: _downloadedFilePercentage,
          url: studyMaterial.fileUrl,
        );

        //download file
        String downloadFilePath = Platform.isAndroid && isPermissionGranted
            ? (await ExternalPath.getExternalStoragePublicDirectory(
                ExternalPath.DIRECTORY_DOWNLOAD,
              ))
            : (await getApplicationDocumentsDirectory()).path;

        downloadFilePath =
            "$downloadFilePath/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

        await writeFileFromTempStorage(
          sourcePath: tempFileSavePath,
          destinationPath: downloadFilePath,
        );

        

        emit(DownloadFileSuccess(downloadFilePath));
      }

      //if user has given permission to download and view file
      final permission = await Permission.storage.request();
      if (permission.isGranted) {
        await thingsToDoAfterPermissionIsGiven(true);
      } else {
        try {
          await thingsToDoAfterPermissionIsGiven(false);
        } catch (e) {
          emit(
            DownloadFileFailure(
              failedToDownloadFileKey,
            ),
          );
        }
      }
    } catch (e) {
      if (_cancelToken.isCancelled) {
        emit(DownloadFileProcessCanceled());
      } else {
        emit(DownloadFileFailure(
          failedToDownloadFileKey,
        ));
      }
    }
  }

  void cancelDownloadProcess() {
    _cancelToken.cancel();
  }
}
