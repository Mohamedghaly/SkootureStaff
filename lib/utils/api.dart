import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class Api {
  static String login = "${databaseUrl}teacher/login";
  static String logout = "${databaseUrl}logout";
  static String schoolDetails = "${databaseUrl}school-details";

  static String passwordResetEmail = "${databaseUrl}forgot-password";
  static String changepassword = "${databaseUrl}change-password";
  static String editProfile = "${databaseUrl}update-profile";
  static String getStaffPermissionAndFeatures =
      "${databaseUrl}staff/features-permission";
  static String getSystemStatistics = "${databaseUrl}staff/counter";
  static String getTeachers = "${databaseUrl}staff/teachers";
  static String getLeaves = "${databaseUrl}leaves";
  static String applyLeave = "${databaseUrl}leaves";

  static String getSettings = "${databaseUrl}settings";
  static String getHolidays = "${databaseUrl}holidays";
  static String getLeaveRequests = "${databaseUrl}staff/leave-request";
  static String approveOrRejectLeaveRequest =
      "${databaseUrl}staff/leave-approve";
  static String getClasses = "${databaseUrl}classes";
  static String getSessionYears = "${databaseUrl}session-years";

  static String getStudents = "${databaseUrl}teacher/student-list";
  static String getStaffs = "${databaseUrl}staff/staffs";
  static String getTimeTableOfTeacher = "${databaseUrl}staff/teacher-timetable";
  static String getUserLeaves = "${databaseUrl}staff-leaves-details";
  static String getStudentAttendanceForStaff =
      "${databaseUrl}staff/student/attendance";
  static String getClassTimetable = "${databaseUrl}staff/class-timetable";
  static String getMediums = "${databaseUrl}medium";
  static String getOfflineExamStudentResults =
      "${databaseUrl}staff/student-offline-exam-result";
  static String getNotifications = "${databaseUrl}staff/notification";
  static String deleteNotification = "${databaseUrl}staff/notification-delete";
  static String getAnnouncements = "${databaseUrl}staff/get-announcement";
  static String deleteGeneralAnnouncement =
      "${databaseUrl}staff/delete-announcement";
  static String sendNotification = "${databaseUrl}staff/notification";
  static String sendGeneralAnnouncement =
      "${databaseUrl}staff/send-announcement";
  static String editGeneralAnnouncement =
      "${databaseUrl}staff/update-announcement";

  static String getMyPayRolls = "${databaseUrl}staff/my-payroll";
  static String downloadPayRollSlip = "${databaseUrl}staff/payroll-slip";
  static String getPayRollYears = "${databaseUrl}staff/payroll-year";
  static String getRoles = "${databaseUrl}staff/roles";
  static String searchUsers = "${databaseUrl}staff/users";
  static String getFees = "${databaseUrl}staff/get-fees";
  static String getStudentsFeeStatus = "${databaseUrl}staff/fees-paid-list";
  static String getStaffsPayroll = "${databaseUrl}staff/payroll-staff-list";
  static String submitStaffsPayroll = "${databaseUrl}staff/payroll-create";
  static String downloadStudentFeeReceipt =
      "${databaseUrl}staff/student-fees-receipt";

  static String getAllowancesAndDeductions =
      "${databaseUrl}staff/allowances-deductions";

  static String getLeaveSettings = "${databaseUrl}leave-settings";

  ///[teacher-related APIs]
  //-------------
  static String getTeacherMyTimetable =
      "${databaseUrl}teacher/teacher_timetable";
  static String getClassesWithTeacherDetails =
      "${databaseUrl}teacher/class-detail";
  static String getExams = "${databaseUrl}teacher/get-exam-list";
  static String getLessons = "${databaseUrl}teacher/get-lesson";
  static String getSubjects = "${databaseUrl}teacher/subjects";
  static String getClassDetails = "${databaseUrl}teacher/class-detail";

  static String createLesson = "${databaseUrl}teacher/create-lesson";
  static String updateLesson = "${databaseUrl}teacher/update-lesson";
  static String deleteLesson = "${databaseUrl}teacher/delete-lesson";

  static String deleteStudyMaterial = "${databaseUrl}teacher/delete-file";
  static String updateStudyMaterial = "${databaseUrl}teacher/update-file";

  static String getTopics = "${databaseUrl}teacher/get-topic";
  static String createTopic = "${databaseUrl}teacher/create-topic";
  static String updateTopic = "${databaseUrl}teacher/update-topic";
  static String deleteTopic = "${databaseUrl}teacher/delete-topic";

  static String getReviewAssignment =
      "${databaseUrl}teacher/get-assignment-submission";
  static String updateReviewAssignment =
      "${databaseUrl}teacher/update-assignment-submission";

  static String getAssignment = "${databaseUrl}teacher/get-assignment";
  static String uploadAssignment = "${databaseUrl}teacher/update-assignment";
  static String deleteAssignment = "${databaseUrl}teacher/delete-assignment";
  static String createAssignment = "${databaseUrl}teacher/create-assignment";

  static String getAnnouncement = "${databaseUrl}teacher/get-announcement";
  static String createAnnouncement = "${databaseUrl}teacher/send-announcement";
  static String deleteAnnouncement =
      "${databaseUrl}teacher/delete-announcement";
  static String updateAnnouncement =
      "${databaseUrl}teacher/update-announcement";

  static String getAttendance = "${databaseUrl}teacher/get-attendance";
  static String submitAttendance = "${databaseUrl}teacher/submit-attendance";

  static String examList = "${databaseUrl}teacher/get-exam-list";
  static String submitExamMarks =
      "${databaseUrl}teacher/submit-exam-marks/subject";

  static String getDiaryCategories = "${databaseUrl}teacher/diary-categories";
  static String createDiaryCategory =
      "${databaseUrl}teacher/create-diary-category";
  static String updateDiaryCategory =
      "${databaseUrl}teacher/update-diary-category";
  static String deleteDiaryCategory =
      "${databaseUrl}teacher/delete-diary-category";
  static String createDiary = "${databaseUrl}teacher/create-diary";
  static String getDiaries = "${databaseUrl}teacher/diaries";
  static String getStudentSubjects = "${databaseUrl}student/subjects";

  /// Chat
  static String chatMessages = "${databaseUrl}message";
  static String readMessages = "${databaseUrl}message/read";
  static String deleteMessages = "${databaseUrl}delete/message";
  static String getUsers = "${databaseUrl}users";
  static String getUserChatHistory = "${databaseUrl}users/chat/history";

  //-------------

  static String downloadStudentResult = "${databaseUrl}student-exan-result-pdf";

  static Map<String, dynamic> headers() {
    final String jwtToken = AuthRepository.getAuthToken();
    final schoolCode = AuthRepository().schoolCode;

    if (kDebugMode) {
      print({"Authorization": "Bearer $jwtToken", "school_code": schoolCode});
    }
    return {
      "Authorization": "Bearer $jwtToken",
      "school-code": schoolCode,
    };
  }

  static Future<Map<String, dynamic>> post({
    required Map<String, dynamic> body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      if (kDebugMode) {
        print(url);
        print(body);
      }
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(body, ListFormat.multiCompatible);
      dio.interceptors.add(CurlLoggerDioInterceptor(convertFormData: true));

      final response = await dio.post(url,
          data: formData,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: (useAuthToken ?? true) ? Options(headers: headers()) : null);

      if (kDebugMode) {
        print("Response : ${response.data}");
      }

      if (bool.parse(response.data['error'].toString())) {
        throw ApiException(response.data['message'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response?.data);
      }
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (kDebugMode) {
        print(url);
        print(queryParameters);
      }
      //
      final Dio dio = Dio();
      dio.interceptors.add(CurlLoggerDioInterceptor(convertFormData: true));

      final response = await dio.get(url,
          queryParameters: queryParameters,
          options: (useAuthToken ?? true) ? Options(headers: headers()) : null);

      if (kDebugMode) {
        print("Response : ${response.data}");
      }

      if (bool.parse(response.data['error'].toString())) {
        if (kDebugMode) {
          print(response.data);
        }

        throw ApiException(response.data['message'].toString());
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.error?.toString());
        print(e.response?.data);
      }
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<void> download(
      {required String url,
      required CancelToken cancelToken,
      required String savePath,
      required Function updateDownloadedPercentage}) async {
    try {
      final Dio dio = Dio();
      await dio.download(url, savePath, cancelToken: cancelToken,
          onReceiveProgress: ((count, total) {
        updateDownloadedPercentage((count / total) * 100);
      }));
    } on DioException catch (e) {
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }
}
