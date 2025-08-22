class Exam {
  int? examID;
  String? examName;
  String? description;
  int? publish;
  String? sessionYear;
  String? examStartingDate;
  String? examEndingDate;
  String? examStatus;
  int? classId;
  String? className;
  List<ExamTimeTable>? examTimetable;

  Exam({
    this.examID,
    this.examName,
    this.description,
    this.publish,
    this.sessionYear,
    this.examStartingDate,
    this.examEndingDate,
    this.examStatus,
    this.classId,
    this.className,
    this.examTimetable,
  });

  String getExamName() {
    return "$examName";
  }

  Exam.fromExamJson(Map<String, dynamic> json) {
    examID = json['id'] ?? 0;
    examName = json['name'] ?? "";
    description = json['description'] ?? "";
    publish = json['publish'] ?? 0;
    sessionYear = json['session_year'] ?? "";
    examStartingDate = json['exam_starting_date'] ?? "";
    examEndingDate = json['exam_ending_date'] ?? "";
    examStatus = json['exam_status'] ?? "";
    classId = json['class_id'] ?? 0;
    className = json['class_name'] ?? "";
    examTimetable = json['timetable']
        ?.map<ExamTimeTable>((e) => ExamTimeTable.fromJson(e))
        .toList();
  }

  @override
  String toString() {
    return examName ?? "";
  }

  @override
  bool operator ==(covariant Exam other) {
    return other.examID == examID;
  }

  @override
  int get hashCode {
    return examID.hashCode;
  }
}

class ExamTimeTable {
  int? id;
  int? totalMarks;
  double? passingMarks;
  String? date;
  String? startingTime;
  String? endingTime;
  String? subjectName;
  int? subjectId;

  ExamTimeTable({
    this.id,
    this.totalMarks,
    this.passingMarks,
    this.date,
    this.startingTime,
    this.endingTime,
    this.subjectName,
  });

  ExamTimeTable.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    totalMarks = json['total_marks'] ?? 0;
    passingMarks = (json['passing_marks'] is int
        ? (json['passing_marks'] as int).toDouble()
        : json['passing_marks'] ?? 0.0) as double;
    date = json['date'] ?? '';
    startingTime = json['starting_time'] ?? '';
    endingTime = json['ending_time'] ?? '';
    subjectName = json['subject_name'] ?? '';
    subjectId = json['class_subject']?['subject_id'] ?? 0;
  }

  @override
  String toString() {
    return subjectName ?? "";
  }

  @override
  bool operator ==(covariant ExamTimeTable other) {
    return other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    return subjectId.hashCode;
  }
}
