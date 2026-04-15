import 'package:eschool_saas_staff/data/models/trip.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/transport/tripsCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TripItemCard extends StatelessWidget {
  final Trip trip;

  const TripItemCard({
    super.key,
    required this.trip,
  });

  Color _getStatusColor() {
    if (trip.isCompleted) return Colors.blue;
    if (trip.isInProgress) return Colors.green;
    return Colors.orange; // upcoming
  }

  Color _getStatusBackgroundColor() {
    if (trip.isCompleted) return Colors.blue.withValues(alpha: 0.1);
    if (trip.isInProgress) return Colors.green.withValues(alpha: 0.1);
    return Colors.orange.withValues(alpha: 0.1); // upcoming
  }

  void _navigateToTripDetails(BuildContext context) {
    // Call the get-trips API with trip_id before navigating
    if (trip.tripId != null) {
      context.read<TripsCubit>().fetchTripDetails(tripId: trip.tripId!);

      // Navigate to trip details screen with trip data
      Get.toNamed(Routes.tripDetailsScreen, arguments: trip);
    } else {
      // If no trip ID, navigate with existing trip data
      Get.toNamed(Routes.tripDetailsScreen, arguments: trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Text(
                  trip.displayRoute,
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
                  color: _getStatusBackgroundColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomTextContainer(
                  textKey: trip.displayStatus,
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

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
              const CustomTextContainer(
                textKey: shiftTimeKey,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              trip.displayShiftTime,
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

          // Stop Details
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              const CustomTextContainer(
                textKey: stopDetailsKey,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              "${trip.totalStops ?? "N/A"} ${Utils.getTranslatedLabel(stopsKey)} - ${trip.stops.fold(0, (total, stop) => total + stop.passengers.length)} ${Utils.getTranslatedLabel(studentsKey)}",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.8),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Trip Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToTripDetails(context),
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
    );
  }
}
