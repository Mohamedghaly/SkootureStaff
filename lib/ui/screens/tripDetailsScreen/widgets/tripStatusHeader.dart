import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/tripDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class TripStatusHeader extends StatelessWidget {
  final TripDetails tripDetails;
  final VoidCallback? onRefresh;

  const TripStatusHeader({
    super.key,
    required this.tripDetails,
    this.onRefresh,
  });

  Color _getStatusColor() {
    switch (tripDetails.status) {
      case TripStatus.upcoming:
        return Colors.orange;
      case TripStatus.inProgress:
        return Colors.green;
      case TripStatus.completed:
        return Colors.blue;
    }
  }

  Color _getStatusBackgroundColor() {
    return _getStatusColor().withValues(alpha: 0.1);
  }

  String _getStatusText() {
    switch (tripDetails.status) {
      case TripStatus.upcoming:
        return tripUpcomingKey;
      case TripStatus.inProgress:
        return inProgressKey;
      case TripStatus.completed:
        return tripCompletedKey;
    }
  }

  Widget _buildRefreshButton(BuildContext context) {
    // Only show refresh button for in-progress trips
    if (tripDetails.status != TripStatus.inProgress) return const SizedBox();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onRefresh,
        icon: const Icon(
          Icons.refresh,
          color: Colors.white,
          size: 20,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with route and status
          Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                  textKey: tripDetails.route,
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
                  textKey: _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildRefreshButton(context),
            ],
          ),

          const SizedBox(height: 16),

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
            child: CustomTextContainer(
              textKey: tripDetails.shiftTime,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.8),
              ),
            ),
          ),

          const SizedBox(height: 16),

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
              CustomTextContainer(
                textKey: Utils.getTranslatedLabel(stopDetailsKey),
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
                  "${tripDetails.totalStops} ${Utils.getTranslatedLabel(stopsKey)} - ${tripDetails.totalPassengers} ${Utils.getTranslatedLabel(passengersKey)}",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
