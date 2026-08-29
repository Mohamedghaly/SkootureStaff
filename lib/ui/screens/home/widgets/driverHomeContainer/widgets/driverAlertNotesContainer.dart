import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/announcement/notificationsCubit.dart';
import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DriverAlertNotesContainer extends StatefulWidget {
  const DriverAlertNotesContainer({super.key});

  @override
  State<DriverAlertNotesContainer> createState() =>
      _DriverAlertNotesContainerState();
}

class _DriverAlertNotesContainerState extends State<DriverAlertNotesContainer> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when widget loads
    Future.delayed(Duration.zero, () {
      context.read<NotificationsCubit>().getNotifications();
    });
  }

  Widget _buildNotificationCard(
      NotificationDetails notification, BoxConstraints constraints) {
    // Responsive card width based on screen size
    double cardWidth;

    if (constraints.maxWidth < 600) {
      // Mobile - 85% of screen width minus padding for better width utilization
      cardWidth =
          (constraints.maxWidth - (appContentHorizontalPadding * 2)) * 0.85;
    } else if (constraints.maxWidth < 900) {
      // Tablet - medium cards
      cardWidth = 320;
    } else {
      // Desktop - larger cards
      cardWidth = 350;
    }

    // Determine background color based on notification type or use alternating colors
    Color backgroundColor;
    Color textColor;

    // Use different background colors for variety - matching the image style
    final index = notification.hashCode % 3;
    switch (index) {
      case 0:
        backgroundColor = const Color(0xFFE7F3FF); // Light blue background
        textColor = const Color(0xFF1565C0); // Dark blue text
        break;
      case 1:
        backgroundColor = const Color(0xFFFFEBEE); // Light pink background
        textColor = const Color(0xFFC62828); // Dark red text
        break;
      default:
        backgroundColor = const Color(0xFFF1F8E9); // Light green background
        textColor = const Color(0xFF2E7D32); // Dark green text
    }

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(
        left: appContentHorizontalPadding,
        right: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section (only if image exists) - same size as notifications screen
          if (notification.image != null && notification.image!.isNotEmpty) ...[
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: notification.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: textColor.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notification Title
                Text(
                  notification.title ?? "Route Update",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Notification Message
                Text(
                  notification.message ?? "No message available",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
          // Notification icon with bell emoji
          const Text(
            "🔔",
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          CustomTextContainer(
            textKey: "noActiveNotificationsRightNow",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextContainer(
            textKey: "notificationEmptyMessage",
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
    );
  }

  Widget _buildSectionHeader() {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final hasNotifications = state is NotificationsFetchSuccess &&
            state.notifications.isNotEmpty;

        return ContentTitleWithViewMoreButton(
          contentTitleKey: alertNoteKey,
          showViewMoreButton: hasNotifications,
          viewMoreOnTap: hasNotifications
              ? () {
                  Get.toNamed(Routes.notificationsScreen);
                }
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 15),
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsFetchInProgress) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: appContentHorizontalPadding),
                    padding: const EdgeInsets.all(32),
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
                    child: Center(
                      child: CustomCircularProgressIndicator(
                        indicatorColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }

                if (state is NotificationsFetchFailure) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: appContentHorizontalPadding),
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        context
                            .read<NotificationsCubit>()
                            .getNotifications();
                      },
                    ),
                  );
                }

                if (state is NotificationsFetchSuccess) {
                  final notifications = state.notifications;

                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Show the latest 2 notifications in horizontal scroll
                  final displayNotifications = notifications.take(2).toList();

                  return SizedBox(
                    height: 100, // Compact height for side-by-side layout
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          EdgeInsets.only(right: appContentHorizontalPadding),
                      itemCount: displayNotifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(
                            displayNotifications[index], constraints);
                      },
                    ),
                  );
                }

                // Initial state - show empty state
                return _buildEmptyState();
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
