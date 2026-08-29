import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/curlLoggerInterceptor.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/unauthenticatedAccessManager.dart';
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
  static String getSchoolSettings = "${databaseUrl}school-settings";
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
  static String getNotifications = "${databaseUrl}notifications";
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
  static String getUsersByRole = "${databaseUrl}users-by-role";
  static String getFees = "${databaseUrl}staff/get-fees";
  static String getStudentsFeeStatus = "${databaseUrl}staff/fees-paid-list";
  static String getStaffsPayroll = "${databaseUrl}staff/payroll-staff-list";
  static String submitStaffsPayroll = "${databaseUrl}staff/payroll-create";
  static String downloadStudentFeeReceipt =
      "${databaseUrl}staff/student-fees-receipt";

  static String getAllowancesAndDeductions =
      "${databaseUrl}staff/allowances-deductions";

  static String getLeaveSettings = "${databaseUrl}leave-settings";

  /// Staff Attendance APIs
  static String getStaffAttendance = "${databaseUrl}staff/staff-attendance";
  static String submitStaffAttendance =
      "${databaseUrl}staff/staff-attendance-store";

  ///[teacher-related APIs]
  //-------------
  static String getTeacherMyTimetable =
      "${databaseUrl}teacher/teacher_timetable";
  static String getClassesWithTeacherDetails =
      "${databaseUrl}teacher/class-detail";
  static String getExams = "${databaseUrl}teacher/get-exam-list";
  static String getLessons = "${databaseUrl}teacher/get-lesson";
  static String getSubjects = "${databaseUrl}teacher/subjects";
  static String getStudentSubjects = "${databaseUrl}teacher/subjects";
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
  static String getTeacherAttendance = "${databaseUrl}staff/attendance";

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
  static String deleteDiary = "${databaseUrl}teacher/delete-diary";
  static String getDiaries = "${databaseUrl}diaries";
  static String getStudentDetails = "${databaseUrl}student-details";

  /// Chat
  static String chatMessages = "${databaseUrl}message";
  static String readMessages = "${databaseUrl}message/read";
  static String deleteMessages = "${databaseUrl}delete/message";
  static String getUsers = "${databaseUrl}users";
  static String getUserChatHistory = "${databaseUrl}users/chat/history";

  //-------------

  /// Transportation
  static String getPickupPoints = "${databaseUrl}pickup-points";
  static String getTransportationShifts = "${databaseUrl}transportation-shifts";
  static String getTransportationFees = "${databaseUrl}transportation-fees";
  static String getTransportDashboard = "${databaseUrl}transport/dashboard";
  static String getCurrentPlan = "${databaseUrl}transport/plans/current";
  static String getVehicleAssignmentStatus =
      "${databaseUrl}get-vehicle-assignment-status";
  static String getTrips = "${databaseUrl}driver-helpr/get-trips";
  static String getUserImage =
      "${databaseUrl}get-image"; // Common endpoint for user images
  static String startEndTrip = "${databaseUrl}driver-helpr/trip/start-end";
  static String createAttendance = "${databaseUrl}transport/attendance/create";
  static String getTransportUserAttendanceList =
      "${databaseUrl}transport/user/attendance-list";
  static String getLiveRoute = "${databaseUrl}transportation/live-route";
  static String getRouteStops = "${databaseUrl}transport/routes/stops";
  static String getTransportRequests = "${databaseUrl}transport/requests";
  static String submitTransportEnrollment =
      "${databaseUrl}transportation-payments";

  // Expense APIs
  static String createTransportationExpense =
      "${databaseUrl}create-transportation-expense";
  static String getExpenseCategories =
      "${databaseUrl}transport/expense/categories/list";
  static String getVehicleDetails =
      "${databaseUrl}driver-helpr/get-vehicle-details";
  static String getTransportationExpenses =
      "${databaseUrl}get-transportation-expense";
  static String storeTripReports = "${databaseUrl}transport/store-trip-reports";

  static String downloadStudentResult = "${databaseUrl}student-exan-result-pdf";
  static String getDriverDashboard = "${databaseUrl}driver-helpr/dashboard";

  /// URLs that should NOT trigger 401 handling (to avoid infinite loops).
  static final Set<String> _authExemptUrls = {login, logout};

  /// Checks if the given URL is exempt from 401 handling.
  static bool _isAuthExemptUrl(String url) {
    return _authExemptUrls.any((exemptUrl) => url.contains(exemptUrl));
  }

  static Map<String, dynamic> headers() {
    final String jwtToken = AuthRepository.getAuthToken();
    final schoolCode = AuthRepository().schoolCode;

    if (kDebugMode) {
      debugPrint({
        "Authorization": "Bearer $jwtToken",
        "school_code": schoolCode
      }.toString());
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
      // Block API calls if user has been force-logged out due to 401
      if (UnauthenticatedAccessManager().isLoggedOut &&
          !_isAuthExemptUrl(url)) {
        throw ApiException(defaultErrorMessageKey);
      }

      if (kDebugMode) {
        debugPrint(url);
        debugPrint(body.toString());
      }
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(body, ListFormat.multiCompatible);
      dio.interceptors.add(CurlLoggerInterceptor(
        printOnSuccess: true,
        printOnError: true,
        convertFormData: true,
      ));

      final response = await dio.post(url,
          data: formData,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: (useAuthToken ?? true) ? Options(headers: headers()) : null);

      // Check for 401 in response body (API returns 200 with error code 401)
      if (_isUnauthorizedResponse(response.data)) {
        _handleUnauthorized(url);
        throw ApiException(defaultErrorMessageKey);
      }

      if (bool.parse(response.data['error'].toString())) {
        throw ApiException(response.data['message'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(e.response?.data?.toString());
      }

      // Handle 401 HTTP status code
      if (e.response?.statusCode == 401 && !_isAuthExemptUrl(url)) {
        _handleUnauthorized(url);
        throw ApiException(defaultErrorMessageKey);
      }

      if (e.error is SocketException) {
        throw ApiException(noInternetKey);
      }
      // Extract error message from API response if available
      if (e.response?.data != null && e.response?.data is Map) {
        final responseData = e.response!.data as Map;
        if (responseData.containsKey('message') &&
            responseData['message'] != null &&
            responseData['message'].toString().isNotEmpty) {
          throw ApiException(responseData['message'].toString());
        }
      }
      throw ApiException(defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    bool skipErrorCheck =
        false, // Add parameter to skip error field check for non-standard APIs
  }) async {
    try {
      // Block API calls if user has been force-logged out due to 401
      if (UnauthenticatedAccessManager().isLoggedOut &&
          !_isAuthExemptUrl(url)) {
        throw ApiException(defaultErrorMessageKey);
      }

      if (kDebugMode) {
        debugPrint(url);
        debugPrint(queryParameters.toString());
      }
      //
      final Dio dio = Dio();
      dio.interceptors.add(CurlLoggerInterceptor(
        printOnSuccess: true,
        printOnError: true,
        convertFormData: true,
      ));

      final response = await dio.get(url,
          queryParameters: queryParameters,
          options: (useAuthToken ?? true) ? Options(headers: headers()) : null);

      // Check for 401 in response body (API returns 200 with error code 401)
      if (_isUnauthorizedResponse(response.data)) {
        _handleUnauthorized(url);
        throw ApiException(defaultErrorMessageKey);
      }

      // Only check 'error' field if skipErrorCheck is false and response contains 'error' field
      if (!skipErrorCheck &&
          response.data is Map &&
          response.data.containsKey('error')) {
        if (bool.parse(response.data['error'].toString())) {
          if (kDebugMode) {
            debugPrint(response.data);
          }

          throw ApiException(response.data['message'].toString());
        }
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(e.error?.toString());
        debugPrint(e.response?.data?.toString());
      }

      // Handle 401 HTTP status code
      if (e.response?.statusCode == 401 && !_isAuthExemptUrl(url)) {
        _handleUnauthorized(url);
        throw ApiException(defaultErrorMessageKey);
      }

      if (e.error is SocketException) {
        throw ApiException(noInternetKey);
      }
      // Extract error message from API response if available
      if (e.response?.data != null && e.response?.data is Map) {
        final responseData = e.response!.data as Map;
        if (responseData.containsKey('message') &&
            responseData['message'] != null &&
            responseData['message'].toString().isNotEmpty) {
          throw ApiException(responseData['message'].toString());
        }
      }
      throw ApiException(defaultErrorMessageKey);
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

  /// Checks if the API response body indicates a 401 Unauthorized error.
  /// Some APIs return HTTP 200 but include a `code: 401` in the response body.
  static bool _isUnauthorizedResponse(dynamic responseData) {
    if (responseData is Map) {
      final code = responseData['code'];
      if (code != null && int.tryParse(code.toString()) == 401) {
        return true;
      }
    }
    return false;
  }

  /// Triggers the global 401 handler (unless the URL is exempt).
  static void _handleUnauthorized(String url) {
    if (!_isAuthExemptUrl(url)) {
      UnauthenticatedAccessManager().handleUnauthorizedAccess();
    }
  }
}
