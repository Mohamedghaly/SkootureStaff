import 'package:eschool_saas_staff/cubits/transport/tripsCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/myTripContainer/widgets/tripItemCard.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverLatestTripContainer extends StatefulWidget {
  final VoidCallback onViewMoreTapped;

  const DriverLatestTripContainer({
    super.key,
    required this.onViewMoreTapped,
  });

  @override
  State<DriverLatestTripContainer> createState() =>
      _DriverLatestTripContainerState();
}

class _DriverLatestTripContainerState extends State<DriverLatestTripContainer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load trips when this widget is first created and displayed
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

  void _loadTrips() {
    final tripsCubit = context.read<TripsCubit>();
    // Always fetch trips to get the latest data
    tripsCubit.fetchTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 10),
      child: Column(
        children: [
          // Header with title and View More button
          ContentTitleWithViewMoreButton(
            contentTitleKey: myTripKey,
            showViewMoreButton: true,
            viewMoreOnTap: widget.onViewMoreTapped,
          ),

          const SizedBox(height: 15),

          // Trip content
          BlocBuilder<TripsCubit, TripsState>(
            builder: (context, state) {
              if (state is TripsFetchInProgress) {
                return Container(
                  height: 150,
                  child: Center(
                    child: CustomCircularProgressIndicator(
                      indicatorColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              } else if (state is TripsFetchFailure) {
                return Container(
                  height: 150,
                  child: Center(
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        context.read<TripsCubit>().fetchTrips();
                      },
                    ),
                  ),
                );
              } else if (state is TripsFetchSuccess) {
                final trips = state.trips;

                if (trips.isEmpty) {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CustomTextContainer(
                        textKey: noTripsFoundKey,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                // Show only the latest trip (first in the list)
                final latestTrip = trips.first;
                return TripItemCard(trip: latestTrip);
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
