import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/overviewDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/screens/staffsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teachersScreen.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class HomeOverviewDetailsContainer extends StatelessWidget {
  const HomeOverviewDetailsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final staffAllowedPermissionsAndModulesCubit =
        context.read<StaffAllowedPermissionsAndModulesCubit>();

    ///
    final showLeaveRequests =
        (staffAllowedPermissionsAndModulesCubit.isModuleEnabled(
                moduleId: staffLeaveManagementModuleId.toString()) &&
            staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
                permission: approveLeavePermissionKey));

    final showTeachers = staffAllowedPermissionsAndModulesCubit
        .isPermissionGiven(permission: viewTeachersPermissionKey);

    final showStudents = staffAllowedPermissionsAndModulesCubit
        .isPermissionGiven(permission: viewStudentsPermissionKey);

    final showStaffs = staffAllowedPermissionsAndModulesCubit.isPermissionGiven(
        permission: viewStaffsPermissionKey);

    return (showStaffs || showStudents || showTeachers || showLeaveRequests)
        ? Column(
            children: [
              const ContentTitleWithViewMoreButton(
                  showViewMoreButton: false, contentTitleKey: overviewKey),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding),
                  children: [
                    showLeaveRequests
                        ? BlocBuilder<HomeScreenDataCubit, HomeScreenDataState>(
                            builder: (context, state) {
                              return OverviewDetailsContainer(
                                  backgroundColor: Theme.of(context)
                                      .extension<CustomColors>()!
                                      .leaveRequestOverviewBackgroundColor!,
                                  titleKey: leaveRequestKey,
                                  value: context
                                      .read<HomeScreenDataCubit>()
                                      .getTotalLeaveRequests()
                                      .toString(),
                                  iconPath:
                                      Utils.getImagePath("leave_overview.svg"),
                                  bottomButtonTitleKey: viewRequestKey,
                                  onTapBottomViewButton: () {
                                    Get.toNamed(Routes.leaveRequestScreen);
                                  });
                            },
                          )
                        : const SizedBox(),
                    showTeachers
                        ? OverviewDetailsContainer(
                            backgroundColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .totalTeacherOverviewBackgroundColor!,
                            titleKey: totalTeachersKey,
                            value: context
                                .read<HomeScreenDataCubit>()
                                .getTotalTeachers()
                                .toString(),
                            iconPath:
                                Utils.getImagePath("teachers_overview.svg"),
                            bottomButtonTitleKey: viewTeachersKey,
                            onTapBottomViewButton: () {
                              Get.toNamed(Routes.teachersScreen,
                                  arguments: TeachersScreen.buildArguments(
                                      teacherNavigationType:
                                          TeacherNavigationType.profile));
                            })
                        : const SizedBox(),
                    showStudents
                        ? OverviewDetailsContainer(
                            backgroundColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .totalStudentOverviewBackgroundColor!,
                            titleKey: totalStudentsKey,
                            value: context
                                .read<HomeScreenDataCubit>()
                                .getTotalStudents()
                                .toString(),
                            iconPath:
                                Utils.getImagePath("students_overview.svg"),
                            bottomButtonTitleKey: viewStudentsKey,
                            onTapBottomViewButton: () {
                              Get.toNamed(Routes.studentsScreen);
                            })
                        : const SizedBox(),
                    showStaffs
                        ? OverviewDetailsContainer(
                            backgroundColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .totalStaffOverviewBackgroundColor!,
                            titleKey: totalStaffsKey,
                            value: context
                                .read<HomeScreenDataCubit>()
                                .getTotalStaffs()
                                .toString(),
                            iconPath: Utils.getImagePath("staffs_overview.svg"),
                            bottomButtonTitleKey: viewStaffsKey,
                            onTapBottomViewButton: () {
                              Get.toNamed(Routes.staffsScreen,
                                  arguments: StaffsScreen.buildArguments(
                                      forStaffLeave: false));
                            })
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
