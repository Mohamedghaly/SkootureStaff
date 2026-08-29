import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/transport/tripsCubit.dart';
import 'package:eschool_saas_staff/data/models/driverDashboardResponse.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DriverLiveTransportContainer extends StatelessWidget {
  final List<LiveTrip> liveTrips;

  const DriverLiveTransportContainer({
    super.key,
    required this.liveTrips,
  });

  // Simple navigation method using only trip_id - exactly like tripItemCard.dart
  void _navigateToTripDetails(BuildContext context, int tripId) {
    // Call the fetchTripDetails API with trip_id before navigating
    context.read<TripsCubit>().fetchTripDetails(tripId: tripId);

    // Navigate to trip details screen - the screen will handle the data from TripsCubit
    Get.toNamed(Routes.tripDetailsScreen);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            ContentTitleWithViewMoreButton(
              contentTitleKey: liveTransportKey,
            ),
            const SizedBox(height: 15),
            if (liveTrips.isEmpty)
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: appContentHorizontalPadding),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Bus icon with emoji
                    const Text(
                      "🚌",
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    CustomTextContainer(
                      textKey: "noActiveTripsRightNow",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextContainer(
                      textKey: "tripsEmptyMessage",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...liveTrips
                  .map((trip) => _buildTripContainer(context, trip))
                  .toList(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildTripContainer(BuildContext context, LiveTrip trip) {
    return GestureDetector(
      onTap: () => _navigateToTripDetails(context, trip.tripId),
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: appContentHorizontalPadding, vertical: 5),
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomTextContainer(
                    textKey:
                        "${trip.from} ${Utils.getTranslatedLabel(toKey)} ${trip.to}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(trip.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomTextContainer(
                    textKey: _getStatusKey(trip.status),
                    style: TextStyle(
                      color: _getStatusColor(trip.status).shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Route Name
            Row(
              children: [
                Icon(
                  Icons.route,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                CustomTextContainer(
                  textKey: routeNameKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: CustomTextContainer(
                textKey: trip.routeName,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Shift Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                CustomTextContainer(
                  textKey: shiftTimeKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: CustomTextContainer(
                textKey:
                    "${trip.shiftTime.from} ${Utils.getTranslatedLabel(toKey)} ${trip.shiftTime.to}",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Trip Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToTripDetails(context, trip.tripId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_bus,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    CustomTextContainer(
                      textKey: tripDetailsKey,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getStatusKey(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return inProgressKey;
      case 'upcoming':
        return upcomingKey;
      case 'completed':
        return completedKey;
      default:
        return status;
    }
  }
}
