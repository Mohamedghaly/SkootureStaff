import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/data/models/driverDashboardResponse.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DriverLeavesContainer extends StatelessWidget {
  final List<StaffOnLeave> staffOnLeave;
  final List<MyLeave> myLeaves;

  const DriverLeavesContainer({
    super.key,
    required this.staffOnLeave,
    required this.myLeaves,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Staff on Leave Section
            ContentTitleWithViewMoreButton(
              contentTitleKey: staffOnLeaveKey,
            ),
            const SizedBox(height: 15),

            // Staff Leave Items
            if (staffOnLeave.isEmpty)
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
                    // Staff icon with emoji
                    const Text(
                      "👥",
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    CustomTextContainer(
                      textKey: allStaffArePresentTodayKey,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextContainer(
                      textKey: staffLeaveEmptyMessageKey,
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
              // Show all staff leave items
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: appContentHorizontalPadding),
                padding:
                    EdgeInsets.symmetric(vertical: appContentHorizontalPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: staffOnLeave
                      .map((staff) => Column(
                            children: [
                              _buildStaffLeaveItem(
                                  context: context, staff: staff),
                              const SizedBox(height: 12),
                            ],
                          ))
                      .toList(),
                ),
              ),

            const SizedBox(height: 20),

            // My Leave Section
            ContentTitleWithViewMoreButton(
              showViewMoreButton: myLeaves.isNotEmpty,
              contentTitleKey: myLeavesKey,
              viewMoreOnTap: myLeaves.isNotEmpty
                  ? () {
                      // Navigate to my leaves screen
                      Get.toNamed(
                        Routes.leavesScreen,
                        arguments: LeavesScreen.buildArguments(
                          showMyLeaves: true,
                          userDetails: null,
                        ),
                      );
                    }
                  : null,
            ),
            const SizedBox(height: 15),

            if (myLeaves.isEmpty)
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
                    // Calendar icon with emoji
                    const Text(
                      "📅",
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    CustomTextContainer(
                      textKey: youHaveNoUpcomingLeavesKey,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextContainer(
                      textKey: myLeavesEmptyMessageKey,
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
              // Show only the first leave item
              Column(
                children: [
                  _buildMyLeaveItem(context, myLeaves.first),
                  const SizedBox(height: 12),
                ],
              ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildStaffLeaveItem({
    required BuildContext context,
    required StaffOnLeave staff,
  }) {
    final isFullDay = staff.leaveType.toLowerCase().contains('full');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Staff Avatar - Square container with rounded corners
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            clipBehavior: Clip.antiAlias,
            child: staff.avtar.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: staff.avtar,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),

          // Staff Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  staff.location,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Leave Type Badge - Exactly as shown in image
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isFullDay ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isFullDay ? Utils.getTranslatedLabel(fullDayKey) : Utils.getTranslatedLabel(halfDayLeaveKey),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isFullDay
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFFF9800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLeaveItem(BuildContext context, MyLeave leave) {
    final isFullDay = leave.leaveType.toLowerCase().contains('full');
    final formattedDate = _formatDate(leave.date);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
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
          // Top row with leave type badge and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leave Type Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isFullDay
                      ? const Color(0xFFEF4444)
                      : Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isFullDay ? Utils.getTranslatedLabel(fullDayKey) : Utils.getTranslatedLabel(halfDayLeaveKey),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              // Date
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reason label
          Text(
            Utils.getTranslatedLabel(reasonKey),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 8),

          // Reason text
          Text(
            leave.reason,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd - MMM').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
