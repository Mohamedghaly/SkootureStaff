import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/driverDashboardCubit.dart';
import 'package:eschool_saas_staff/cubits/announcement/notificationsCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/tripsCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/driverHomeContainer/widgets/driverHolidaysContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/driverHomeContainer/widgets/driverLatestTripContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/driverHomeContainer/widgets/driverLeavesContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/driverHomeContainer/widgets/driverNewStudentContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/driverHomeContainer/widgets/driverAlertNotesContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/homeContainerAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverHomeContainer extends StatefulWidget {
  final VoidCallback? onNavigateToMyTrips;

  const DriverHomeContainer({super.key, this.onNavigateToMyTrips});

  @override
  State<DriverHomeContainer> createState() => _DriverHomeContainerState();

  /// Static method to refresh driver home data from outside
  static void refreshData(GlobalKey key) {
    final state = key.currentState;
    if (state != null && state is _DriverHomeContainerState) {
      state.getDriverHomeScreenData();
    }
  }
}

class _DriverHomeContainerState extends State<DriverHomeContainer> {
  Widget _buildAppBar() {
    final profileImage =
        (context.read<AuthCubit>().getUserDetails().image ?? "");

    return HomeContainerAppbar(profileImage: profileImage);
  }

  void getDriverHomeScreenData() {
    context.read<DriverDashboardCubit>().getDriverDashboard();
  }

  void _navigateToMyTripsTab() {
    // Call the callback passed from HomeScreen to navigate to My Trips tab
    widget.onNavigateToMyTrips?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocConsumer<StaffAllowedPermissionsAndModulesCubit,
            StaffAllowedPermissionsAndModulesState>(
          listener: (context, state) {
            if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
              getDriverHomeScreenData();
            }
          },
          builder: (context, state) {
            if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
              return BlocBuilder<DriverDashboardCubit, DriverDashboardState>(
                builder: (context, driverDashboardState) {
                  if (driverDashboardState is DriverDashboardFetchSuccess) {
                    return RefreshIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      displacement: MediaQuery.of(context).padding.top + 100,
                      onRefresh: () async {
                        getDriverHomeScreenData();
                      },
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 80,
                            bottom: 100),
                        child: Column(
                          children: [
                            BlocProvider(
                              create: (context) => TripsCubit(),
                              child: DriverLatestTripContainer(
                                onViewMoreTapped: _navigateToMyTripsTab,
                              ),
                            ),
                            DriverNewStudentContainer(
                              newPassengers: driverDashboardState
                                  .dashboardData.newPassenger,
                            ),
                            DriverLeavesContainer(
                              staffOnLeave: driverDashboardState
                                  .dashboardData.staffOnLeave,
                              myLeaves:
                                  driverDashboardState.dashboardData.myLeaves,
                            ),
                            BlocProvider(
                              create: (context) => NotificationsCubit(),
                              child: const DriverAlertNotesContainer(),
                            ),
                            DriverHolidaysContainer(
                              driverHolidays:
                                  driverDashboardState.dashboardData.holidays,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (driverDashboardState is DriverDashboardFetchFailure) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * (0.175)),
                        child: ErrorContainer(
                          errorMessage: driverDashboardState.errorMessage,
                          onTapRetry: () {
                            getDriverHomeScreenData();
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
