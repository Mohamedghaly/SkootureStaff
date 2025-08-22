import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class PickedStudyMaterial {
  final String fileName;
  final int
      pickedStudyMaterialTypeId; // 1 = file_upload , 2 = youtube_link , 3 = video_upload , 4 = other_link
  final String? youTubeLink;
  final String? otherLink;
  final PlatformFile? videoThumbnailFile;
  final PlatformFile? studyMaterialFile;

  PickedStudyMaterial({
    required this.fileName,
    required this.pickedStudyMaterialTypeId,
    this.studyMaterialFile,
    this.videoThumbnailFile,
    this.youTubeLink,
    this.otherLink,
  });

  String get studyMaterialFileString {
    switch (pickedStudyMaterialTypeId) {
      case 1:
        return 'file_upload';
      case 2:
        return 'youtube_link';
      case 3:
        return 'video_upload';
      case 4:
        return 'other_link';
      default:
        return '';
    }
  }

  Future<Map<String, dynamic>> toJson() async {
    Map<String, dynamic> json = {};
    json['type'] = studyMaterialFileString;
    json['name'] = fileName;

    if (pickedStudyMaterialTypeId != 2 && pickedStudyMaterialTypeId != 4) {
      if (studyMaterialFile != null) {
        json['file'] = await MultipartFile.fromFile(studyMaterialFile!.path!);
      }
      json['id'] = pickedStudyMaterialTypeId;
    }
    if (pickedStudyMaterialTypeId != 1) {
      if (videoThumbnailFile != null) {
        json['thumbnail'] =
            await MultipartFile.fromFile(videoThumbnailFile!.path!);
      }
      json['id'] = pickedStudyMaterialTypeId;
    }
    if (pickedStudyMaterialTypeId == 2) {
      json['link'] = youTubeLink;
      json['id'] = pickedStudyMaterialTypeId;
    }
    if (pickedStudyMaterialTypeId == 4) {
      json['link'] = otherLink;
      json['id'] = pickedStudyMaterialTypeId;
    }

    return json;
  }
}
