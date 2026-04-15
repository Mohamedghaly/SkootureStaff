import 'package:eschool_saas_staff/ui/screens/aboutUsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/addAnnouncementScreen.dart';
import 'package:eschool_saas_staff/ui/screens/addNotification/addNotificationScreen.dart';
import 'package:eschool_saas_staff/ui/screens/allowancesAndDeductionsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/applyLeaveScreen.dart';
import 'package:eschool_saas_staff/ui/screens/changePasswordScreen.dart';
import 'package:eschool_saas_staff/ui/screens/classTimeTableScreen.dart';
import 'package:eschool_saas_staff/ui/screens/classesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/contactUsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/editAnnouncementScreen.dart';
import 'package:eschool_saas_staff/ui/screens/editProfileScreen.dart';
import 'package:eschool_saas_staff/ui/screens/examsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/generalLeavesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/holidaysScreen.dart';
import 'package:eschool_saas_staff/ui/screens/home/homeScreen.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatScreen.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/newChatContactsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/selectTransport/staffTransportEnrollScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/selectTransport/requestSubmittedScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/transportHomeScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/attendanceScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/transportPlanDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/busRouteScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/changeRouteScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/transportRequestDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/planRenewal/planRenewalScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/planRenewal/planRenewalReviewScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/techerMyAttendanceScreen.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/tripDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/myExpenseScreen/myExpenseScreen.dart';
import 'package:eschool_saas_staff/ui/screens/leaveRequestsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/login/loginScreen.dart';
import 'package:eschool_saas_staff/ui/screens/manageAnnouncement/manageAnnouncementScreen.dart';
import 'package:eschool_saas_staff/ui/screens/manageDiary/addNoteScreen.dart';
import 'package:eschool_saas_staff/ui/screens/manageDiary/manageCategoryScreen.dart';
import 'package:eschool_saas_staff/ui/screens/manageDiary/studentDiaryScreen.dart';
import 'package:eschool_saas_staff/ui/screens/manageDiary/studentDiarySelectionScreen.dart';
import 'package:eschool_saas_staff/ui/screens/manageNotification/manageNotificationScreen.dart';
import 'package:eschool_saas_staff/ui/screens/managePayrolls/managePayrollsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/myPayrollScreen.dart';
import 'package:eschool_saas_staff/ui/screens/notificationsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/offlineResult/offlineResultScreen.dart';
import 'package:eschool_saas_staff/ui/screens/paidFeesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/privacyPolicyScreen.dart';
import 'package:eschool_saas_staff/ui/screens/searchTeachersScreen.dart';
import 'package:eschool_saas_staff/ui/screens/searchUsersScreen.dart';
import 'package:eschool_saas_staff/ui/screens/selectUsersByRoleScreen.dart';
import 'package:eschool_saas_staff/ui/screens/sessionYearsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/splashScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffsScreen.dart';

import 'package:eschool_saas_staff/ui/screens/onbordingScreen.dart';
import 'package:eschool_saas_staff/ui/screens/studentProfileScreen.dart';
import 'package:eschool_saas_staff/ui/screens/studentsAttendanceScreen.dart';
import 'package:eschool_saas_staff/ui/screens/studentsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddAttendanceScreeen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditAnnouncementScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditAssignmentScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditLessonScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditTopicScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherClassSectionScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherEditAssignmentSubmission.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherExamResultScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherManageAnnouncementScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherManageAssignmentScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherManageAssignmentSubmissionScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherManageLessonScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherManageTopicScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherMyTimetableScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherViewAttendanceScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherProfileScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherTimeTableDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teachersScreen.dart';
import 'package:eschool_saas_staff/ui/screens/termsAndConditionScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffAttendance/staffAttendanceScreen.dart';
import 'package:get/route_manager.dart';

class Routes {
  static String splashScreen = "/splash";
  static String onbordingScreen = "/onbording";

  static String homeScreen = "/";
  static String loginScreen = "/login";
  static String teachersScreen = "/teachers";
  static String teacherProfileScreen = "/teacherProfile";
  static String staffsScreen = "/staffs";
  static String staffDetailsScreen = "/staffDetails";
  static String studentsScreen = "/students";
  static String studentProfileScreen = "/studentProfile";
  static String leaveRequestScreen = "/leaveRequest";
  static String teacherTimeTableDetailsScreen = "/teacherTimeTableDetails";
  static String generalLeavesScreen = "/generalLeaves";
  static String holidaysScreen = "/holidays";
  static String applyLeaveScreen = "/applyLeave";
  static String leavesScreen = "/leaves";
  static String studentsAttendanceScreen = "/studentsAttendance";
  static String offlineResultScreen = "/offlineResult";
  static String manageNotificationScreen = "/manageNotification";
  static String addNotificationScreen = "/addNotification";
  static String manageAnnouncementScreen = "/manageAnnouncement";
  static String addAnnouncementScreen = "/addAnnouncement";
  static String paidFeesScreen = "/paidFees";
  static String managePayrollScreen = "/managePayroll";
  static String myPayrollScreen = "/myPayroll";
  static String editProfileScreen = "/editProfile";
  static String changePasswordScreen = "/changePassword";
  static String searchTeachersScreen = "/searchTeachers";
  static String selectUsersByRoleScreen = "/selectUsersByRole";
  static String notificationsScreen = "/notifications";
  static String classesScreen = "/classes";
  static String classTimetableScreen = "/classTimetable";
  static String examsScreen = "/exams";
  static String editAnnouncementScreen = "/editAnnouncement";
  static String searchUsersScreen = "/searchUsers";
  static String aboutUsScreen = "/aboutUs";
  static String contactUsScreen = "/contactUS";
  static String privacyPolicyScreen = "/privacyPolicy";
  static String termsAndConditionScreen = "/termsAndCondition";

  static String sessionYearsScreen = "/sessionYears";
  static String allowancesAndDeductionsScreen = "/allowancesAndDeductions";

  //manage diary routes
  static String addNoteScreen = "/addNote";
  static String manageCategoryScreen = "/manageCategory";
  static String studentDiaryScreen = "/studentDiary";
  static String studentDiarySelectionScreen = "/studentDiarySelection";

  //teacher academics routes
  static String teacherMyTimetableScreen = "/teacherMyTimetable";
  static String teacherClassSectionScreen = "/teacherClassSection";
  static String teacherAddAttendanceScreen = "/teacherAddAttendance";
  static String teacherViewAttendanceScreen = "/teacherViewAttendance";
  static String teacherManageLessonScreen = "/teacherManageLesson";
  static String teacherManageTopicScreen = "/teacherManageTopic";
  static String teacherManageAssignmentScreen = "/teacherManageAssignment";
  static String teacherManageAssignmentSubmissionScreen =
      "/teacherManageAssignmentSubmissionScreen";
  static String teacherManageAnnouncementScreen = "/teacherManageAnnouncement";

  static String teacherExamResultScreen = "/teacherExamResult";
  static String teacherAddEditLessonScreen = "/teacherAddEditLessonScreen";
  static String teacherAddEditTopicScreen = "/teacherAddEditTopicScreen";
  static String teacherAddEditAnnouncementScreen =
      teacherAddEditAnnouncementScreen = "/teacherAddEditAnnouncementScreen";
  static String teacherAddEditAssignmentScreen =
      "/teacherAddEditAssignmentScreen";
  static String teacherEditAssignmentSubmissionScreen =
      "/teacherEditAssignmentSubmissionScreen";

  static String chatScreen = "/chat";
  static String chatContacts = "/chatContacts";
  static String newChatContactsScreen = "/newChatContactsScreen";
  static String teacherMyAttendanceScreen = "/teacherMyAttendance";
  static String staffAttendanceScreen = "/staffAttendance";

  static String tripDetailsScreen = "/tripDetails";
  static String myExpenseScreen = "/myExpense";
  static String staffTransportEnrollScreen = "/staffTransportEnroll";
  static String transportEnrollSubmittedScreen = "/transportEnrollSubmitted";
  static String planRenewalScreen = "/planRenewal";
  static String planRenewalReviewScreen = "/planRenewalReview";
  static String transportEnrollHomeScreen = "/transportEnrollHome";
  static String transportPlanDetailsScreen = "/transportPlanDetails";
  static String busRouteScreen = "/busRoute";
  static String changeRouteScreen = "/changeRoute";
  static String attendanceScreen = "/attendance";
  static String transportRequestDetailsScreen = "/transportRequestDetails";

  static final List<GetPage> getPages = [
    GetPage(
      name: splashScreen,
      page: () => SplashScreen.getRouteInstance(),
      transition: Transition.fade, // You can use fade, rightToLeft, etc.
      transitionDuration: Duration(milliseconds: 800), // Adjust as needed
    ),
    GetPage(
        name: onbordingScreen, page: () => OnbordingScreen.getRouteInstance()),
    GetPage(name: loginScreen, page: () => LoginScreen.getRouteInstance()),
    GetPage(name: homeScreen, page: () => HomeScreen.getRouteInstance()),
    GetPage(
        name: teachersScreen, page: () => TeachersScreen.getRouteInstance()),
    GetPage(
        name: teacherProfileScreen,
        page: () => TeacherProfileScreen.getRouteInstance()),
    GetPage(name: staffsScreen, page: () => StaffsScreen.getRouteInstance()),
    GetPage(
        name: staffDetailsScreen,
        page: () => StaffDetailsScreen.getRouteInstance()),
    GetPage(
        name: studentsScreen, page: () => StudentsScreen.getRouteInstance()),
    GetPage(
        name: studentProfileScreen,
        page: () => StudentProfileScreen.getRouteInstance()),
    GetPage(
        name: leaveRequestScreen,
        page: () => LeaveRequestsScreen.getRouteInstance()),
    GetPage(
        name: teacherTimeTableDetailsScreen,
        page: () => TeacherTimeTableDetailsScreen.getRouteInstance()),
    GetPage(
        name: generalLeavesScreen,
        page: () => GeneralLeavesScreen.getRouteInstance()),
    GetPage(
        name: holidaysScreen, page: () => HolidaysScreen.getRouteInstance()),
    GetPage(
        name: applyLeaveScreen,
        page: () => ApplyLeaveScreen.getRouteInstance()),
    GetPage(name: leavesScreen, page: () => LeavesScreen.getRouteInstance()),
    GetPage(
        name: studentsAttendanceScreen,
        page: () => StudentsAttendanceScreen.getRouteInstance()),
    GetPage(
        name: staffAttendanceScreen,
        page: () => StaffAttendanceScreen.getRouteInstance()),
    GetPage(
        name: attendanceScreen,
        page: () => AttendanceScreen.getRouteInstance()),
    GetPage(
        name: offlineResultScreen,
        page: () => OfflineResultScreen.getRouteInstance()),
    GetPage(
        name: manageNotificationScreen,
        page: () => ManageNotificationScreen.getRouteInstance()),
    GetPage(
        name: addNotificationScreen,
        page: () => AddNotificationScreen.getRouteInstance()),
    GetPage(
        name: manageAnnouncementScreen,
        page: () => ManageAnnouncementScreen.getRouteInstance()),
    GetPage(
        name: addAnnouncementScreen,
        page: () => AddAnnouncementScreen.getRouteInstance()),
    GetPage(
        name: editAnnouncementScreen,
        page: () => EditAnnouncementScreen.getRouteInstance()),
    GetPage(
        name: paidFeesScreen, page: () => PaidFeesScreen.getRouteInstance()),
    GetPage(
        name: managePayrollScreen,
        page: () => ManagePayrollsScreen.getRouteInstance()),
    GetPage(
        name: myPayrollScreen, page: () => MyPayrollScreen.getRouteInstance()),
    GetPage(
        name: editProfileScreen,
        page: () => EditProfileScreen.getRouteInstance()),
    GetPage(
        name: changePasswordScreen,
        page: () => ChangePasswordScreen.getRouteInstance()),
    GetPage(name: aboutUsScreen, page: () => AboutUsScrren.getRouteInstance()),
    GetPage(
        name: contactUsScreen, page: () => ContactUsScreen.getRouteInstance()),
    GetPage(
        name: privacyPolicyScreen,
        page: () => PrivacyPolicyScreen.getRouteInstance()),
    GetPage(
        name: termsAndConditionScreen,
        page: () => TermsAndConditionScreen.getRouteInstance()),
    GetPage(
        name: searchTeachersScreen,
        page: () => SearchTeachersScreen.getRouteInstance()),
    GetPage(
        name: selectUsersByRoleScreen,
        page: () => SelectUsersByRoleScreen.getRouteInstance()),
    GetPage(
        name: notificationsScreen,
        page: () => NotificationsScreen.getRouteInstance()),
    GetPage(name: classesScreen, page: () => ClassesScreen.getRouteInstance()),
    GetPage(
      name: teacherMyTimetableScreen,
      page: () => TeacherMyTimetableScreen.getRouteInstance(),
    ),
    GetPage(
      name: classTimetableScreen,
      page: () => ClassTimeTableScreen.getRouteInstance(),
    ),
    GetPage(
      name: sessionYearsScreen,
      page: () => SessionYearsScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherClassSectionScreen,
      page: () => TeacherClassSectionScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherAddAttendanceScreen,
      page: () => TeacherAddAttendanceScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherViewAttendanceScreen,
      page: () => TeacherViewAttendanceScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherManageLessonScreen,
      page: () => TeacherManageLessonScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherManageTopicScreen,
      page: () => TeacherManageTopicScreen.getRouteInstance(),
      popGesture: false,
    ),
    GetPage(
      name: teacherManageAssignmentScreen,
      page: () => TeacherManageAssignmentScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherManageAssignmentSubmissionScreen,
      page: () => TeacherManageAssignmentSubmissionScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherManageAnnouncementScreen,
      page: () => TeacherManageAnnouncementScreen.getRouteInstance(),
    ),
    GetPage(
      name: examsScreen,
      page: () => ExamsScreen.getRouteInstance(),
    ),
    GetPage(
      name: searchUsersScreen,
      popGesture: false,
      page: () => SearchUsersScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherExamResultScreen,
      page: () => TeacherExamResultScreen.getRouteInstance(),
    ),
    GetPage(
      name: teacherAddEditLessonScreen,
      page: () => TeacherAddEditLessonScreen.getRouteInstance(),
      popGesture: false,
    ),
    GetPage(
      name: teacherAddEditTopicScreen,
      page: () => TeacherAddEditTopicScreen.getRouteInstance(),
      popGesture: false,
    ),
    GetPage(
      name: teacherAddEditAnnouncementScreen,
      page: () => TeacherAddEditAnnouncementScreen.getRouteInstance(),
      popGesture: false,
    ),
    GetPage(
      name: teacherAddEditAssignmentScreen,
      page: () => TeacherAddEditAssignmentScreen.getRouteInstance(),
      popGesture: false,
    ),
    GetPage(
      name: teacherEditAssignmentSubmissionScreen,
      page: () => TeacherEditAssignmentSubmissionScreen.getRouteInstance(),
    ),
    GetPage(
      name: allowancesAndDeductionsScreen,
      page: () => AllowancesAndDeductionsScreen.getRouteInstance(),
    ),

    GetPage(
      name: chatContacts,
      page: () => ChatContainer.getRouteInstance(),
    ),
    GetPage(name: chatScreen, page: () => ChatScreen.getRouteInstance()),
    GetPage(
        name: newChatContactsScreen,
        page: () => NewChatContactsScreen.getRouteInstance()),

    GetPage(
      name: teacherMyAttendanceScreen,
      page: () => TeacherMyAttendanceScreen.getRouteInstance(),
    ),

    //manage diary routes
    GetPage(name: addNoteScreen, page: () => AddNoteScreen.getRouteInstance()),
    GetPage(
        name: manageCategoryScreen,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>?;
          final type = arguments?['type'] as String? ?? "positive";
          return ManageCategoryScreen.getRouteInstance(type: type);
        }),
    GetPage(
        name: studentDiaryScreen,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>?;
          final studentId = arguments?['studentId'] as int? ?? 0;
          return StudentDiaryScreen.getRouteInstance(studentId: studentId);
        }),
    GetPage(
        name: studentDiarySelectionScreen,
        page: () => StudentDiarySelectionScreen.getRouteInstance()),

    // Trip Details Route
    GetPage(
      name: tripDetailsScreen,
      page: () => TripDetailsScreen.getRouteInstance(),
    ),
    GetPage<dynamic>(
      name: myExpenseScreen,
      page: () => MyExpenseScreen.getRouteInstance(),
    ),

    // Staff transport enrollment
    GetPage(
      name: staffTransportEnrollScreen,
      page: () => StaffTransportEnrollScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportEnrollSubmittedScreen,
      page: () => RequestSubmittedScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportEnrollHomeScreen,
      page: () => TransportHomeScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportPlanDetailsScreen,
      page: () => TransportPlanDetailsScreen.getRouteInstance(),
    ),
    GetPage(
      name: busRouteScreen,
      page: () => BusRouteScreen.getRouteInstance(),
    ),
    GetPage(
      name: changeRouteScreen,
      page: () => ChangeRouteScreen.getRouteInstance(),
    ),
    GetPage(
      name: attendanceScreen,
      page: () => AttendanceScreen.getRouteInstance(),
    ),
    GetPage(
      name: transportRequestDetailsScreen,
      page: () => TransportRequestDetailsScreen(
        transportRequest: Get.arguments,
      ),
    ),
    GetPage(
      name: planRenewalScreen,
      page: () => PlanRenewalScreen.getRouteInstance(),
    ),
    GetPage(
      name: planRenewalReviewScreen,
      page: () => PlanRenewalReviewScreen.getRouteInstance(),
    ),
  ];
}
