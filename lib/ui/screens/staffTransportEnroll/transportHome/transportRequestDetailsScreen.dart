import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/transportRequest.dart'
    as TransportRequestModel;
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/statusTag.dart';

class TransportRequestDetailsScreen extends StatelessWidget {
  final TransportRequestModel.TransportRequest transportRequest;

  const TransportRequestDetailsScreen({
    super.key,
    required this.transportRequest,
  });

  /// Get status colors based on request status
  Map<String, Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return {
          'background': const Color(0xFFE8F5E8),
          'foreground': const Color(0xFF2E7D32),
        };
      case 'rejected':
        return {
          'background': const Color(0xFFF9D2D2),
          'foreground': const Color(0xFFB71C1C),
        };
      case 'pending':
        return {
          'background': const Color(0xFFFEEED7),
          'foreground': const Color(0xFF9E6C2C),
        };
      default:
        return {
          'background': const Color(0xFFF5F5F5),
          'foreground': const Color(0xFF9E9E9E),
        };
    }
  }

  /// Get footer note based on request status
  String _getFooterNote(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Your transportation request has been approved. The new plan is now active.';
      case 'rejected':
        return 'Your request was rejected. Please contact the transport department for alternate arrangements or refund.';
      case 'pending':
        return 'Your request is being processed';
      default:
        return 'Please contact the transport department for more information.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = _getStatusColors(transportRequest.status);
    final footerNote = _getFooterNote(transportRequest.status);
    final showNewRequest = transportRequest.isRejected;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppbar(
              titleKey: Utils.getTranslatedLabel(requestDetailsKey),
              showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: appContentHorizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  CustomTextContainer(
                    textKey: 'Transportation Request',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Main Card with all details
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Requested On with Status Badge
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                context,
                                'Requested On',
                                transportRequest.requestedOn,
                              ),
                            ),
                            StatusTag(
                              text: transportRequest.statusDisplay,
                              bg: statusColors['background']!,
                              fg: statusColors['foreground']!,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Requested By
                        if (transportRequest.requestedBy.name.isNotEmpty) ...[
                          _buildDetailItem(
                            context,
                            'Requested By',
                            transportRequest.requestedBy.name,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Pickup Location
                        if (transportRequest
                            .details.pickupStop.name.isNotEmpty) ...[
                          _buildDetailItem(
                            context,
                            Utils.getTranslatedLabel(pickupLocationKey),
                            transportRequest.details.pickupStop.name,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Plan Duration
                        if (transportRequest
                            .details.plan.duration.isNotEmpty) ...[
                          _buildDetailItem(
                            context,
                            Utils.getTranslatedLabel(planDurationKey),
                            transportRequest.details.plan.duration,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Plan Validity
                        if (transportRequest
                            .details.plan.validity.isNotEmpty) ...[
                          _buildDetailItem(
                            context,
                            'Plan Validity',
                            transportRequest.details.plan.validity,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Responded On
                        if (transportRequest.review != null &&
                            transportRequest
                                .review!.respondedOn.isNotEmpty) ...[
                          _buildDetailItem(
                            context,
                            'Responded On',
                            transportRequest.review!.respondedOn,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // School Email
                        if (transportRequest
                            .contactDetails.schoolEmail.isNotEmpty) ...[
                          _buildDetailItem(
                            context,
                            Utils.getTranslatedLabel(schoolEmailKey),
                            transportRequest.contactDetails.schoolEmail,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // School Phone (Last item - no bottom spacing)
                        if (transportRequest
                            .contactDetails.schoolPhone.isNotEmpty)
                          _buildDetailItem(
                            context,
                            Utils.getTranslatedLabel(schoolPhoneKey),
                            transportRequest.contactDetails.schoolPhone,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Footer note
            CustomTextContainer(
              textKey: footerNote,
              style: TextStyle(
                fontSize: 12,
                color: transportRequest.status.toLowerCase() == 'rejected'
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                if (showNewRequest)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      child: CustomTextContainer(
                        textKey: Utils.getTranslatedLabel(newRequestKey),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (showNewRequest) const SizedBox(width: 12),
                Expanded(
                  child: CustomRoundedButton(
                    textSize: 15,
                    onTap: () {
                      final phoneNumber =
                          transportRequest.contactDetails.schoolPhone;
                      if (phoneNumber.isNotEmpty) {
                        Utils.launchCallLog(mobile: phoneNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(Utils.getTranslatedLabel(
                                phoneNumberNotAvailableKey)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: contactSupportKey,
                    showBorder: false,
                    widthPercentage: 1.0,
                    height: 50,
                    radius: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single detail item (label + value)
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextContainer(
          textKey: label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6D6E6F),
          ),
        ),
        const SizedBox(height: 4),
        CustomTextContainer(
          textKey: value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
