import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/roundedBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/leaveDetailsContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherLeavesContainer extends StatelessWidget {
  const TeacherLeavesContainer({super.key});

  bool _hasLeaveViewPermission(BuildContext context) {
    final permissionCubit =
        context.read<StaffAllowedPermissionsAndModulesCubit>();
    // Check if the leave management module is enabled and user has permission to view leaves
    return permissionCubit.isModuleEnabled(
        moduleId: staffLeaveManagementModuleId.toString());
  }

  void _handleViewMoreTap(BuildContext context) {
    if (_hasLeaveViewPermission(context)) {
      Get.toNamed(Routes.generalLeavesScreen);
    } else {
      Utils.showSnackBar(
        message: noLeavePermissionKey,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final todaysLeave = context.read<HomeScreenDataCubit>().getTodayLeaves();
    final hasPermission = _hasLeaveViewPermission(context);

    return RoundedBackgroundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentTitleWithViewMoreButton(
            contentTitleKey: leavesKey,
            showViewMoreButton: true,
            viewMoreOnTap: () => _handleViewMoreTap(context),
          ),
          const SizedBox(
            height: 15,
          ),
          // Show appropriate content based on permissions first, then data
          !hasPermission
              ? Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding),
                  child:
                      const CustomTextContainer(textKey: noLeavePermissionKey),
                )
              : todaysLeave.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: appContentHorizontalPadding),
                      child: const CustomTextContainer(
                          textKey: everyoneIsPresentTodayKey),
                    )
                  : Column(
                      children: [
                        LeaveDetailsContainer(
                          leaveDetails: todaysLeave.first,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        todaysLeave.length > 1
                            ? LeaveDetailsContainer(
                                leaveDetails: todaysLeave[1])
                            : const SizedBox(),
                      ],
                    ),
        ],
      ),
    );
  }
}
