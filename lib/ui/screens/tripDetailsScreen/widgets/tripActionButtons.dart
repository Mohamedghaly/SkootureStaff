import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/tripDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class TripActionButtons extends StatelessWidget {
  final TripDetails tripDetails;
  final VoidCallback onStartTrip;
  final VoidCallback? onCompleteTrip;

  const TripActionButtons({
    super.key,
    required this.tripDetails,
    required this.onStartTrip,
    this.onCompleteTrip,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we should show any buttons
    final shouldShowButtons = _shouldShowButtons();

    // If no buttons to show, return empty widget without Container/SafeArea wrapper
    if (!shouldShowButtons) {
      return const SizedBox.shrink();
    }

    // Only wrap in Container and SafeArea when we have buttons to show
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
        vertical: 16,
      ),
      child: SafeArea(
        child: _buildButtonsForStatus(context),
      ),
    );
  }

  // Helper method to determine if buttons should be shown
  bool _shouldShowButtons() {
    switch (tripDetails.status) {
      case TripStatus.upcoming:
        return true; // Always show Start Trip button
      case TripStatus.inProgress:
        // Show Complete Trip button only when all stops are completed
        return tripDetails.allStopsCompleted && onCompleteTrip != null;
      case TripStatus.completed:
        return false; // Never show buttons for completed trips
    }
  }

  Widget _buildButtonsForStatus(BuildContext context) {
    switch (tripDetails.status) {
      case TripStatus.upcoming:
        return Row(
          children: [
            // Start Trip Button
            Expanded(
              child: ElevatedButton(
                onPressed: onStartTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: CustomTextContainer(
                  textKey: Utils.getTranslatedLabel(startTripKey),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      case TripStatus.inProgress:
        // Show Complete Trip button only when all stops are completed
        return Row(
          children: [
            // Complete Trip Button
            Expanded(
              child: ElevatedButton(
                onPressed: onCompleteTrip!,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: CustomTextContainer(
                  textKey: Utils.getTranslatedLabel(completeTripKey),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      case TripStatus.completed:
        // This should never be reached due to _shouldShowButtons check
        return const SizedBox.shrink();
    }
  }
}
