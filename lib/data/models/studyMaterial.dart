import 'package:eschool_saas_staff/utils/labelKeys.dart';

enum StudyMaterialType {
  file,
  youtubeVideo,
  uploadedVideoUrl,
  other,
  otherLink
}

StudyMaterialType getStudyMaterialType(int type) {
  if (type == 1) {
    return StudyMaterialType.file;
  }
  if (type == 2) {
    return StudyMaterialType.youtubeVideo;
  }
  if (type == 3) {
    return StudyMaterialType.uploadedVideoUrl;
  }
  if (type == 4) {
    return StudyMaterialType.otherLink;
  }

  return StudyMaterialType.other;
}

int getStudyMaterialIdByEnum(
  StudyMaterialType studyMaterialType,
) {
  if (studyMaterialType == StudyMaterialType.file) {
    return 1;
  }
  if (studyMaterialType == StudyMaterialType.youtubeVideo) {
    return 2;
  }
  if (studyMaterialType == StudyMaterialType.uploadedVideoUrl) {
    return 3;
  }
  if (studyMaterialType == StudyMaterialType.otherLink) {
    return 4;
  }
  return 0;
}

String getStudyMaterialTypeLabelKeyByEnum(
  StudyMaterialType studyMaterialType,
) {
  if (studyMaterialType == StudyMaterialType.file) {
    return fileUploadKey;
  }
  if (studyMaterialType == StudyMaterialType.youtubeVideo) {
    return youtubeLinkKey;
  }
  if (studyMaterialType == StudyMaterialType.uploadedVideoUrl) {
    return videoUploadKey;
  }
  if (studyMaterialType == StudyMaterialType.otherLink) {
    return otherLinkKey;
  }
  return "Other";
}

class StudyMaterial {
  late final StudyMaterialType studyMaterialType;
  late final int id;
  late final String fileName;
  late final String fileThumbnail;
  late final String fileUrl;
  late final String fileExtension;

  StudyMaterial.fromJson(Map<String, dynamic> json) {
    studyMaterialType = getStudyMaterialType(int.parse(json['type'] ?? "0"));
    id = json['id'] ?? 0;
    fileName = json['file_name'] ?? "";
    fileThumbnail = json['file_thumbnail'] ?? "";
    fileUrl = json['file_url'] ?? "";
    fileExtension = json['file_extension'] ?? "";
  }

  StudyMaterial.fromURL(String url) {
    fileUrl = url;
    fileExtension = url.split('.').last.toString();
    studyMaterialType = StudyMaterialType.file;
    id = 0;
    fileName = url.split("/").last.toString();
    fileThumbnail = '';
  }
}

class StudyMaterialTypeItem {
  final int type;
  final String title;

  StudyMaterialType get studyMaterialType => getStudyMaterialType(type);

  int get id {
    if (studyMaterialType == StudyMaterialType.file) {
      return 1;
    } else if (studyMaterialType == StudyMaterialType.youtubeVideo) {
      return 2;
    } else if (studyMaterialType == StudyMaterialType.uploadedVideoUrl) {
      return 3;
    } else if (studyMaterialType == StudyMaterialType.otherLink) {
      return 4;
    } else {
      return 0;
    }
  }

  StudyMaterialTypeItem({
    required this.type,
    required this.title,
  });

  @override
  bool operator ==(covariant StudyMaterialTypeItem other) {
    return other.type == type;
  }

  @override
  int get hashCode {
    return type.hashCode;
  }

  @override
  String toString() {
    return title;
  }
}
