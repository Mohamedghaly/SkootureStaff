import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/holidaysContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/homeOverviewContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/leavesContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/teachersTimeTableContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/homeContainerAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({super.key});

  static GlobalKey<HomeContainerState> widgetKey =
      GlobalKey<HomeContainerState>();

  @override
  State<HomeContainer> createState() => HomeContainerState();
}

class HomeContainerState extends State<HomeContainer> {
  void getHomeScreenData() {
    context.read<HomeScreenDataCubit>().getHomeScreenData(
        holidayModuleEnabled: context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isModuleEnabled(moduleId: holidayManagementModuleId.toString()),
        staffLeaveModuleEnabled: context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isModuleEnabled(moduleId: staffLeaveManagementModuleId.toString()),
        isTeacher: false,
        listTeacherTimetablePermission: context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isPermissionGiven(permission: viewTeachersPermissionKey));
  }

  void updateLeaveRequestCount({required int totalLeaveRequests}) {
    context
        .read<HomeScreenDataCubit>()
        .updateLeaveRequest(totalLeaveRequests: totalLeaveRequests);
  }

  Widget _buildAppBar() {
    final profileImage =
        (context.read<AuthCubit>().getUserDetails().image ?? "");

    return HomeContainerAppbar(profileImage: profileImage);
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
                      child: Column(
                        children: [
                          const HomeOverviewDetailsContainer(),
                          context
                                  .read<
                                      StaffAllowedPermissionsAndModulesCubit>()
                                  .isModuleEnabled(
                                      moduleId: timetableManagementModuleId
                                          .toString())
                              ? const TeachersTimeTableContainer()
                              : const SizedBox(),
                          const LeavesContainer(),
                          const HolidaysContainer()
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
              });
            }

            if (state is StaffAllowedPermissionsAndModulesFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context
                        .read<StaffAllowedPermissionsAndModulesCubit>()
                        .getPermissionAndAllowedModules();
                  },
                ),
              );
            }

            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        _buildAppBar(),
      ],
    );
  }
}
