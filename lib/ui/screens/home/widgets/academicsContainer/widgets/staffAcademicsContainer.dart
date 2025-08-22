import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menusWithTitleContainer.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teachersScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customMenuTile.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class StaffAcademicsContainer extends StatelessWidget {
  const StaffAcademicsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final StaffAllowedPermissionsAndModulesCubit
        staffAllowedPermissionsAndModulesCubit =
        context.read<StaffAllowedPermissionsAndModulesCubit>();
    return Column(
      children: [
        staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                permission: viewClassesPermissionKey)
            ? MenusWithTitleContainer(title: classKey, menus: [
                CustomMenuTile(
                    iconImageName: "classes.svg",
                    titleKey: viewClassesKey,
                    onTap: () {
                      Get.toNamed(Routes.classesScreen);
                    }),
              ])
            : const SizedBox(),
        staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                permission: viewSessionYearsPermissionKey)
            ? MenusWithTitleContainer(title: sessionYearKey, menus: [
                CustomMenuTile(
                    iconImageName: "session_year.svg",
                    titleKey: viewSessionYearsKey,
                    onTap: () {
                      Get.toNamed(Routes.sessionYearsScreen);
                    }),
              ])
            : const SizedBox(),
        MenusWithTitleContainer(title: leaveKey, menus: [
          CustomMenuTile(
              iconImageName: "apply_leave.svg",
              titleKey: applyLeaveKey,
              onTap: () {
                Get.toNamed(Routes.applyLeaveScreen);
              }),
          CustomMenuTile(
              iconImageName: "my_leave.svg",
              titleKey: myLeaveKey,
              onTap: () {
                Get.toNamed(Routes.leavesScreen,
                    arguments: LeavesScreen.buildArguments(showMyLeaves: true));
              }),
          (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                      moduleId: staffLeaveManagementModuleId.toString()) &&
                  staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                      permission: approveLeavePermissionKey))
              ? CustomMenuTile(
                  iconImageName: "staff_leave.svg",
                  titleKey: staffLeaveKey,
                  onTap: () {
                    Get.toNamed(Routes.staffsScreen,
                        arguments:
                            StaffsScreen.buildArguments(forStaffLeave: true));
                  })
              : const SizedBox(),
          (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                      moduleId: staffLeaveManagementModuleId.toString()) &&
                  staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                      permission: approveLeavePermissionKey))
              ? CustomMenuTile(
                  iconImageName: "staff_leave.svg",
                  titleKey: teacherLeaveKey,
                  onTap: () {
                    Get.toNamed(
                      Routes.teachersScreen,
                      arguments: TeachersScreen.buildArguments(
                          teacherNavigationType: TeacherNavigationType.leave),
                    );
                  })
              : const SizedBox(),
        ]),
        (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                    moduleId: attendanceManagementModuleId.toString()) &&
                staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                    permission: viewStudentAttendancePermissionKey))
            ? MenusWithTitleContainer(title: attendanceKey, menus: [
                CustomMenuTile(
                    iconImageName: "student_attendance.svg",
                    titleKey: studentAttendanceKey,
                    onTap: () {
                      Get.toNamed(Routes.studentsAttendanceScreen);
                    }),
              ])
            : const SizedBox(),
        (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                    moduleId: timetableManagementModuleId.toString()) &&
                staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                    permission: viewTimetablePermissionKey))
            ? MenusWithTitleContainer(title: timetableKey, menus: [
                CustomMenuTile(
                    iconImageName: "class_timetable.svg",
                    titleKey: classTimetableKey,
                    onTap: () {
                      Get.toNamed(Routes.classTimetableScreen);
                    }),
                CustomMenuTile(
                    iconImageName: "teacher_timetable.svg",
                    titleKey: teachersTimetableKey,
                    onTap: () {
                      Get.toNamed(
                        Routes.teachersScreen,
                        arguments: TeachersScreen.buildArguments(
                            teacherNavigationType:
                                TeacherNavigationType.timetable),
                      );
                    }),
              ])
            : const SizedBox(),
        (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                    moduleId: examManagementModuleId.toString())) &&
                (staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                        permission: viewExamsPermissionKey) ||
                    staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                        permission: viewExamResultPermissionKey))
            ? MenusWithTitleContainer(title: offlineExamKey, menus: [
                staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                        permission: viewExamsPermissionKey)
                    ? CustomMenuTile(
                        iconImageName: "exams.svg",
                        titleKey: examsKey,
                        onTap: () {
                          Get.toNamed(Routes.examsScreen);
                        })
                    : const SizedBox(),
                staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                        permission: viewExamResultPermissionKey)
                    ? CustomMenuTile(
                        iconImageName: "offline_result.svg",
                        titleKey: offlineResultKey,
                        onTap: () {
                          Get.toNamed(Routes.offlineResultScreen);
                        })
                    : const SizedBox(),
              ])
            : const SizedBox(),
        (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                        moduleId: announcementManagementModuleId.toString()) &&
                    staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                        permission: viewNotificationPermissionKey)) ||
                (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                        moduleId: announcementManagementModuleId.toString()) &&
                    staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                        permission: viewAnnouncementPermissionKey))
            ? MenusWithTitleContainer(title: messageKey, menus: [
                (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                            moduleId:
                                announcementManagementModuleId.toString()) &&
                        staffAllowedPermissionsAndModulesCubit
                            .isPermissionGiven(
                                permission: viewNotificationPermissionKey))
                    ? CustomMenuTile(
                        iconImageName: "manage_notification.svg",
                        titleKey: manageNotificationKey,
                        onTap: () {
                          Get.toNamed(Routes.manageNotificationScreen);
                        })
                    : const SizedBox(),
                (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                            moduleId:
                                announcementManagementModuleId.toString()) &&
                        staffAllowedPermissionsAndModulesCubit
                            .isPermissionGiven(
                                permission: viewAnnouncementPermissionKey))
                    ? CustomMenuTile(
                        iconImageName: "announcement.svg",
                        titleKey: manageAnnouncementKey,
                        onTap: () {
                          Get.toNamed(Routes.manageAnnouncementScreen);
                        })
                    : const SizedBox(),
              ])
            : const SizedBox(),
        (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                    moduleId: feesManagementModuleId.toString())) ||
                (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                    moduleId: expenseManagementModuleId.toString()))
            ? MenusWithTitleContainer(title: paymentKey, menus: [
                (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                            moduleId: feesManagementModuleId.toString()) &&
                        staffAllowedPermissionsAndModulesCubit
                            .isPermissionGiven(
                                permission: viewFeesPaidPermissionKey))
                    ? CustomMenuTile(
                        iconImageName: "paid_fees.svg",
                        titleKey: paidFeesKey,
                        onTap: () {
                          Get.toNamed(Routes.paidFeesScreen);
                        })
                    : const SizedBox(),
                (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                            moduleId: expenseManagementModuleId.toString()) &&
                        staffAllowedPermissionsAndModulesCubit
                            .isPermissionGiven(
                                permission: viewPayrollListPermissionKey))
                    ? CustomMenuTile(
                        iconImageName: "manage_payroll.svg",
                        titleKey: managePayRollsKey,
                        onTap: () {
                          Get.toNamed(Routes.managePayrollScreen);
                        })
                    : const SizedBox(),
                staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                        moduleId: expenseManagementModuleId.toString())
                    ? context.read<AuthCubit>().getUserDetails().isSchoolAdmin()
                        ? const SizedBox()
                        : CustomMenuTile(
                            iconImageName: "my_payroll.svg",
                            titleKey: myPayRollKey,
                            onTap: () {
                              Get.toNamed(Routes.myPayrollScreen);
                            })
                    : const SizedBox(),
                //
                staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                        moduleId: expenseManagementModuleId.toString())
                    ? CustomMenuTile(
                        iconImageName: "allowances_and_deductions.svg",
                        titleKey: allowancesAndDeductionsKey,
                        onTap: () {
                          Get.toNamed(Routes.allowancesAndDeductionsScreen);
                        })
                    : const SizedBox(),
              ])
            : const SizedBox(),
      ],
    );
  }
}
