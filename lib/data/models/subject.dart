import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:get/get.dart';

class Subject {
  final int? id;
  final String? name;
  final String? code;
  final String? bgColor;
  final String? image;
  final int? mediumId;

  ///[Theory and Practical]
  final String? type;

  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? nameWithType;

  Subject({
    this.id,
    this.name,
    this.code,
    this.bgColor,
    this.image,
    this.mediumId,
    this.type,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.nameWithType,
  });

  Subject copyWith({
    int? id,
    String? name,
    String? code,
    String? bgColor,
    String? image,
    int? mediumId,
    String? type,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    String? nameWithType,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      bgColor: bgColor ?? this.bgColor,
      image: image ?? this.image,
      mediumId: mediumId ?? this.mediumId,
      type: type ?? this.type,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nameWithType: nameWithType ?? this.nameWithType,
    );
  }

  Subject.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        code = json['code'] as String?,
        bgColor = json['bg_color'] as String?,
        image = json['image'] as String?,
        mediumId = json['medium_id'] as int?,
        type = json['type'] as String?,
        schoolId = json['school_id'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        deletedAt = json['deleted_at'] as String?,
        nameWithType = json['name_with_type'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'bg_color': bgColor,
        'image': image,
        'medium_id': mediumId,
        'type': type,
        'school_id': schoolId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'name_with_type': nameWithType
      };
  bool isTheorySubject() {
    return type == "Theory"; //Practical
  }

  String getSybjectNameWithType() {
    if ((type ?? "").isEmpty) {
      return nameWithType ?? "";
    }
    String subjectTypeTranslated =
        isTheorySubject() ? theoryKey.tr : practicalKey.tr;
    return "$name - $subjectTypeTranslated";
  }
}
