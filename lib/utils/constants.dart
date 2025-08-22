import 'package:eschool_saas_staff/data/models/assignmentSubmission.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

///[Do not add / at the end of the url]`

const String baseUrl = "https://skooture.ai";

const String databaseUrl = "$baseUrl/api/";

// our Socket url
const socketUrl = "ws://193.203.162.252:8090";

// Web socket ping interval
const socketPingInterval = Duration(seconds: 275);

///[Socket events]
enum SocketEvent { register, message }

double appContentHorizontalPadding = 15.0;
double horizontalCompetitionListHeight = 70.0;
double bottomsheetBorderRadius = 15.0;
Duration snackBarDuration = const Duration(milliseconds: 1000);
Duration tabDuration = const Duration(milliseconds: 500);
Duration tileCollapsedDuration = const Duration(milliseconds: 500);
int nextSearchRequestQueryTimeInMilliSeconds = 700;
int searchRequestPerodicMilliSeconds = 100;
double topPaddingOfErrorAndLoadingContainer = 150;

String defaultSchoolCode = "SCH202412";
String defaultEmail = "teacher@gmail.com";
String defaultPassword = "0111111111";

List<String> months = [
  januaryKey,
  februaryKey,
  marchKey,
  aprilKey,
  mayKey,
  juneKey,
  julyKey,
  augustKey,
  septemberKey,
  octoberKey,
  novemberKey,
  decemberKey,
];

enum LeaveDayType { today, tomorrow, upcoming }

int getLeaveDayTypeStatus({required LeaveDayType leaveDayType}) {
  if (leaveDayType == LeaveDayType.tomorrow) {
    return 1;
  }

  if (leaveDayType == LeaveDayType.upcoming) {
    return 2;
  }

  return 0;
}

int getSatusValueFromKey({required String value}) {
  if (value == activeKey) {
    return 1;
  }
  if (value == inactiveKey) {
    return 2;
  }

  return 0;
}

const List<String> weekDays = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

String getLeaveTypeValueFromKey({required String leaveTypeKey}) {
  if (leaveTypeKey == firstHalfKey) {
    return "First Half";
  }
  if (leaveTypeKey == secondHalfKey) {
    return "Second Half";
  }
  return "Full";
}

///[ 0 -> Pending, 1 -> Approved, 2 -> Rejected ]
enum LeaveRequestStatus { pending, approved, rejected }

LeaveRequestStatus getLeaveRequestStatusEnumFromValue(int status) {
  if (status == 1) {
    return LeaveRequestStatus.approved;
  }

  if (status == 2) {
    return LeaveRequestStatus.rejected;
  }

  return LeaveRequestStatus.pending;
}

String getLeaveRequestStatusKey(LeaveRequestStatus leaveRequestStatus) {
  if (leaveRequestStatus == LeaveRequestStatus.approved) {
    return approvedKey;
  }

  if (leaveRequestStatus == LeaveRequestStatus.rejected) {
    return rejectedKey;
  }

  return pendingKey;
}

enum StudentListStatus { all, active, inactive }

// 0 => Absent, 1 => Present
enum StudentAttendanceStatus { absent, present }

StudentAttendanceStatus getStudentAttendanceStatusFromValue(int status) {
  if (status == 0) {
    return StudentAttendanceStatus.absent;
  }

  return StudentAttendanceStatus.present;
}

String getStudentAttendanceStatusKey(
  StudentAttendanceStatus studentAttendanceStatus,
) {
  if (studentAttendanceStatus == StudentAttendanceStatus.absent) {
    return absentKey;
  }
  return presentKey;
}

//assignment submission statuses
final List<AssignmentSubmissionStatus> allAssignmentSubmissionStatus = [
  AssignmentSubmissionStatus(
    typeStatusId: -1,
    titleKey: allKey,
    filter: AssignmentSubmissionFilters.all,
    color: Colors.black,
  ),
  AssignmentSubmissionStatus(
    typeStatusId: 0,
    titleKey: pendingKey,
    filter: AssignmentSubmissionFilters.submitted,
    color: Colors.orange,
  ),
  AssignmentSubmissionStatus(
    typeStatusId: 1,
    titleKey: acceptedKey,
    filter: AssignmentSubmissionFilters.accepted,
    color: Colors.green,
  ),
  AssignmentSubmissionStatus(
    typeStatusId: 2,
    titleKey: rejectedKey,
    filter: AssignmentSubmissionFilters.rejected,
    color: Colors.red,
  ),
  AssignmentSubmissionStatus(
    typeStatusId: 3,
    titleKey: resubmittedKey,
    filter: AssignmentSubmissionFilters.resubmitted,
    color: Colors.orange,
  ),
];

//For Study Material type dropdown itemsain
List<StudyMaterialTypeItem> allStudyMaterialTypeItems = [
  StudyMaterialTypeItem(type: 1, title: fileUploadKey),
  StudyMaterialTypeItem(type: 2, title: youtubeLinkKey),
  StudyMaterialTypeItem(type: 3, title: videoUploadKey),
  StudyMaterialTypeItem(type: 4, title: otherLinkKey),
];

const String teacherRoleKey = "Teacher";
const String studentRoleKey = "Student";
const String guardianRoleKey = "Guardian";

const String allUserSendNotificationTypeKey = "All users";
const String specificUserSendNotificationTypeKey = "Specific users";
const String overDueFeesNotificationTypeKey = "Over Due Fees";
const String specificRolesSendNotificationTypeKey = "Roles";

const String schoolAdminRoleKey = "School Admin";
