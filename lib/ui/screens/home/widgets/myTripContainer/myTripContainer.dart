import 'package:eschool_saas_staff/cubits/transport/tripsCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/myTripContainer/widgets/tripItemCard.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyTripContainer extends StatefulWidget {
  const MyTripContainer({super.key});

  @override
  State<MyTripContainer> createState() => _MyTripContainerState();

  // Static method to refresh data from outside
  static void refreshData(GlobalKey key) {
    final widget = key.currentWidget as MyTripContainer?;
    if (widget != null) {
      final state = key.currentState as _MyTripContainerState?;
      state?.refreshData();
    }
  }
}

class _MyTripContainerState extends State<MyTripContainer>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true; // Keep the tab alive when switching

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load trips when this widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app comes to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      _loadTrips();
    }
  }

  // Expose method to refresh data from parent
  void refreshData() {
    if (mounted) {
      _loadTrips();
    }
  }

  void _loadTrips() {
    final tripsCubit = context.read<TripsCubit>();
    // Always fetch trips to get the latest data
    tripsCubit.fetchTrips();
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary)),
        color: Theme.of(context).colorScheme.surface,
      ),
      height: 70 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: appContentHorizontalPadding,
          right: appContentHorizontalPadding),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Row(
        children: [
          const Expanded(
            child: CustomTextContainer(
              textKey: myTripKey,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              displacement: MediaQuery.of(context).padding.top + 100,
              onRefresh: () async {
                // Always fetch trips when user explicitly refreshes
                await context.read<TripsCubit>().fetchTrips();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 80,
                  bottom: 100,
                  left: appContentHorizontalPadding,
                  right: appContentHorizontalPadding,
                ),
                child: BlocBuilder<TripsCubit, TripsState>(
                  builder: (context, state) {
                    if (state is TripsFetchInProgress) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.3),
                          child: CustomCircularProgressIndicator(
                            indicatorColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    } else if (state is TripsFetchFailure) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.3),
                          child: ErrorContainer(
                            errorMessage: state.errorMessage,
                            onTapRetry: () {
                              // Always fetch trips when user taps retry
                              context.read<TripsCubit>().fetchTrips();
                            },
                          ),
                        ),
                      );
                    } else if (state is TripsFetchSuccess) {
                      final trips = state.trips;

                      if (trips.isEmpty) {
                        return Center(
                          child: noDataContainer(
                            titleKey: noTripsFoundKey,
                          ),
                        );
                      }

                      return Column(
                        children: trips.map((trip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TripItemCard(trip: trip),
                          );
                        }).toList(),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            _buildAppBar(),
          ],
        );
      },
    );
  }
}
