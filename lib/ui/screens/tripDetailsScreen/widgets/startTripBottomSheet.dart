import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class StartTripBottomSheet extends StatefulWidget {
  final String routeName;
  final String shiftTime;
  final int stopCount;
  final int studentCount;
  final Function(String tripType) onStartTrip;

  const StartTripBottomSheet({
    super.key,
    required this.routeName,
    required this.shiftTime,
    required this.stopCount,
    required this.studentCount,
    required this.onStartTrip,
  });

  @override
  State<StartTripBottomSheet> createState() => _StartTripBottomSheetState();
}

class _StartTripBottomSheetState extends State<StartTripBottomSheet> {
  String _selectedTripType = 'pickup'; // Default to pickup
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          // Header
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextContainer(
                    textKey: Utils.getTranslatedLabel(selectTripTypeKey),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Trip Info Card
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                  textKey: widget.routeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomTextContainer(
                    textKey: Utils.getTranslatedLabel(tripUpcomingKey),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    CustomTextContainer(
                      textKey: Utils.getTranslatedLabel(shiftTimeKey),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: CustomTextContainer(
                    textKey: widget.shiftTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
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
                  padding: const EdgeInsets.only(left: 22),
                  child: CustomTextContainer(
                    textKey:
                        "${widget.stopCount} ${Utils.getTranslatedLabel(stopsKey)} - ${widget.studentCount} ${Utils.getTranslatedLabel(studentsKey)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Trip Type Selection
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                  textKey: Utils.getTranslatedLabel(tripTypeKey),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Pickup Trip Option
                _buildTripTypeOption(
                  title: Utils.getTranslatedLabel(pickupTripKey),
                  description: Utils.getTranslatedLabel(pickupTripDescriptionKey),
                  value: 'pickup',
                  isSelected: _selectedTripType == 'pickup',
                  onTap: () => setState(() => _selectedTripType = 'pickup'),
                ),

                const SizedBox(height: 12),

                // Drop Trip Option
                _buildTripTypeOption(
                  title: Utils.getTranslatedLabel(dropTripKey),
                  description: Utils.getTranslatedLabel(dropTripDescriptionKey),
                  value: 'drop',
                  isSelected: _selectedTripType == 'drop',
                  onTap: () => setState(() => _selectedTripType = 'drop'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Start Trip Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: appContentHorizontalPadding,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() => _isLoading = true);
                        widget.onStartTrip(_selectedTripType);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : CustomTextContainer(
                        textKey: Utils.getTranslatedLabel(startTripKey),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeOption({
    required String title,
    required String description,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextContainer(
                    textKey: title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomTextContainer(
                    textKey: description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
