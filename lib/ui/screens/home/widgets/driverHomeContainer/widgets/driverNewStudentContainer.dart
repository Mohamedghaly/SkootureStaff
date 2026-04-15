import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/data/models/driverDashboardResponse.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverNewStudentContainer extends StatelessWidget {
  final List<NewPassenger> newPassengers;

  const DriverNewStudentContainer({
    super.key,
    required this.newPassengers,
  });

  Widget _buildPassengerCard(BuildContext context, NewPassenger passenger) {
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
      child: Column(
        children: [
          // Top row: Image, Name, Phone Icon, Chat Icon
          Row(
            children: [
              // Student Avatar - Square container with rounded corners like the image
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                ),
                clipBehavior: Clip.antiAlias,
                child: passenger.avtar.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: passenger.avtar,
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

              // Student Name
              Expanded(
                child: Text(
                  passenger.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Action Buttons - Phone and Chat icons
              Row(
                children: [
                  // Phone Icon
                  GestureDetector(
                    onTap: () {
                      _handlePhoneCall(context, passenger);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD), // Light blue background
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.phone,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Chat Icon
                  GestureDetector(
                    onTap: () {
                      _handleChatNavigation(context, passenger);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD), // Light blue background
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom section: Shift Time and Pickup Point information below the image
          Row(
            children: [
              // Left side: Shift Time and Pickup Point information below the image
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shift Time Label and Value
                    Text(
                      Utils.getTranslatedLabel(shiftTimeLabelKey),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${passenger.shiftTime.from} ${Utils.getTranslatedLabel(toKey)} ${passenger.shiftTime.to}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Pickup Point Label and Value
                    Text(
                      Utils.getTranslatedLabel(pickupPointLabelKey),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      passenger.pickupPoint.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePhoneCall(BuildContext context, NewPassenger passenger) {
    if (passenger.mobile.isNotEmpty) {
      Utils.launchCallLog(mobile: passenger.mobile);
    } else {
      Utils.showSnackBar(
        message: 'Phone number not available for ${passenger.name}',
        context: context,
      );
    }
  }

  void _handleChatNavigation(BuildContext context, NewPassenger passenger) {
    Get.toNamed(
      Routes.chatScreen,
      arguments: ChatScreen.buildArguments(
        receiverId: passenger.id,
        receiverName: passenger.name,
        receiverImage: passenger.avtar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            ContentTitleWithViewMoreButton(
              contentTitleKey: newStudentKey,
            ),
            const SizedBox(height: 15),
            if (newPassengers.isEmpty)
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
                    // Student icon with emoji
                    const Text(
                      "🎓",
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    CustomTextContainer(
                      textKey: noNewStudentsTodayKey,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextContainer(
                      textKey: newStudentsEmptyMessageKey,
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
              // Build passenger cards
              ...newPassengers
                  .map((passenger) => Column(
                        children: [
                          _buildPassengerCard(context, passenger),
                          const SizedBox(height: 10),
                        ],
                      ))
                  .toList(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
