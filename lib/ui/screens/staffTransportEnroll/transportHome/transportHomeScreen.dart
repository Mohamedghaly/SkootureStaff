import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/routeStopsCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportDashboardCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportRequestCubit.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/busInfoCard.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/liveTrackingCard.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/transportPlanCard.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/transportRequest.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/shimmerSummaryWidget.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransportHomeScreen extends StatefulWidget {
  const TransportHomeScreen({super.key});

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => RouteStopsCubit()),
          BlocProvider(create: (context) => TransportDashboardCubit()),
          BlocProvider(create: (context) => TransportRequestCubit()),
        ],
        child: const TransportHomeScreen(),
      );

  @override
  State<TransportHomeScreen> createState() => _TransportHomeScreenState();
}

class _TransportHomeScreenState extends State<TransportHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start shimmer animation
    _shimmerController.repeat();

    Future.delayed(Duration.zero, () {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _fetchData() {
    final authCubit = context.read<AuthCubit>();
    final userDetails = authCubit.getUserDetails();
    final userId = userDetails.id ?? 0;

    if (userId > 0) {
      // Fetch route stops data (this is the main API call)
      context.read<RouteStopsCubit>().fetchRouteStops(userId: userId);

      context.read<TransportDashboardCubit>().fetchDashboard(
            userId: userId,
          );
    }
  }

  void _refreshData() {
    final authCubit = context.read<AuthCubit>();
    final userDetails = authCubit.getUserDetails();
    final userId = userDetails.id ?? 0;

    if (userId > 0) {
      context.read<RouteStopsCubit>().refreshRouteStops(userId: userId);

      context.read<TransportDashboardCubit>().fetchDashboard(
            userId: userId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const CustomAppbar(
            titleKey: transportationKey,
            showBackButton: true,
          ),
          Expanded(
            child: BlocConsumer<RouteStopsCubit, RouteStopsState>(
              listener: (context, state) {
                if (state is RouteStopsFetchFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is RouteStopsInitial ||
                    (state is RouteStopsFetchInProgress && !state.isRefresh)) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: TransportHomeShimmerWidget(
                      shimmerAnimation: _shimmerAnimation,
                    ),
                  );
                }

                if (state is RouteStopsFetchFailure && !state.wasRefresh) {
                  return Center(
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: _fetchData,
                    ),
                  );
                }

                final cubit = context.read<RouteStopsCubit>();
                if (!cubit.hasData) {
                  return RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async => _refreshData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 200,
                        child: noDataContainer(
                          titleKey: noTransportationDataFoundKey,
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () async => _refreshData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 460;
                        final columnGap = isWide ? 16.0 : 12.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TransportPlanCard(),
                            SizedBox(height: columnGap),
                            const BusInfoCard(),
                            SizedBox(height: columnGap),
                            const LiveTrackingCard(),
                            SizedBox(height: columnGap),
                            const AttendanceCard(),
                            SizedBox(height: columnGap),
                            const TransportRequestWidget(),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
