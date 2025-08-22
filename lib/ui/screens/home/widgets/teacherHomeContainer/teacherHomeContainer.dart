import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/homeContainerAppbar.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/teacherHolidaysContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/teacherHomeOverviewContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/teacherLeavesContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/teacherTodaysTimetableContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherHomeContainer extends StatefulWidget {
  const TeacherHomeContainer({super.key});

  @override
  State<TeacherHomeContainer> createState() => _TeacherHomeContainerState();
}

class _TeacherHomeContainerState extends State<TeacherHomeContainer> {
  Widget _buildAppBar() {
    final profileImage =
        (context.read<AuthCubit>().getUserDetails().image ?? "");

    return HomeContainerAppbar(profileImage: profileImage);
  }

  void getHomeScreenData() {
    context.read<HomeScreenDataCubit>().getHomeScreenData(
        holidayModuleEnabled: context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isModuleEnabled(moduleId: holidayManagementModuleId.toString()),
        staffLeaveModuleEnabled: context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isModuleEnabled(moduleId: staffLeaveManagementModuleId.toString()),
        listTeacherTimetablePermission: false,
        isTeacher: true);
    if (context
        .read<StaffAllowedPermissionsAndModulesCubit>()
        .isModuleEnabled(moduleId: timetableManagementModuleId.toString())) {
      context
          .read<TeacherMyTimetableCubit>()
          .getTeacherMyTimetable(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocConsumer<StaffAllowedPermissionsAndModulesCubit,
            StaffAllowedPermissionsAndModulesState>(
          listener: (context, state) {
            if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
              getHomeScreenData();
            }
          },
          builder: (context, state) {
            if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
              return BlocBuilder<HomeScreenDataCubit, HomeScreenDataState>(
                builder: (context, homeScreenDataState) {
                  if (homeScreenDataState is HomeScreenDataFetchSuccess) {
                    return RefreshIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      displacement: MediaQuery.of(context).padding.top + 100,
                      onRefresh: () async {
                        getHomeScreenData();
                      },
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 80,
                            bottom: 100),
                        child: const Column(
                          children: [
                            TeacherHomeOverviewContainer(),
                            TeacherTodaysTimetableContainer(),
                            TeacherLeavesContainer(),
                            TeacherHolidaysContainer(),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (homeScreenDataState is HomeScreenDataFetchFailure) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * (0.175)),
                        child: ErrorContainer(
                          errorMessage: homeScreenDataState.errorMessage,
                          onTapRetry: () {
                            getHomeScreenData();
                          },
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * (0.175)),
                      child: CustomCircularProgressIndicator(
                        indicatorColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              );
            } else if (state is StaffAllowedPermissionsAndModulesFetchFailure) {
              return ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  context
                      .read<StaffAllowedPermissionsAndModulesCubit>()
                      .getPermissionAndAllowedModules();
                },
              );
            } else {
              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          },
        ),
        _buildAppBar(),
      ],
    );
  }
}
