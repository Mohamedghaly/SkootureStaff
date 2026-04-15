import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/tripReportCubit.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class DriverReportIssueBottomSheet extends StatefulWidget {
  final int tripId;
  final int? lastReachedStopId; // Optional: for mid-trip reports

  const DriverReportIssueBottomSheet({
    super.key,
    required this.tripId,
    this.lastReachedStopId,
  });

  static void show(
    BuildContext context,
    int tripId, {
    int? lastReachedStopId,
  }) {
    // Store root context for snackbars
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocProvider(
          create: (context) => TripReportCubit(),
          child: BlocListener<TripReportCubit, TripReportState>(
            listener: (context, state) {
              if (state is TripReportSubmitSuccess) {
                // Show success snackbar on root context
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
                // Close the bottom sheet
                Navigator.pop(bottomSheetContext);
              } else if (state is TripReportSubmitFailure) {
                // Show error snackbar on root context
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content: Text(Utils.getTranslatedLabel(
                      state.errorMessage,
                    )),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: DriverReportIssueBottomSheet(
              tripId: tripId,
              lastReachedStopId: lastReachedStopId,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<DriverReportIssueBottomSheet> createState() =>
      _DriverReportIssueBottomSheetState();
}

class _DriverReportIssueBottomSheetState
    extends State<DriverReportIssueBottomSheet> {
  String? selectedIssue;
  final TextEditingController _descriptionController = TextEditingController();
  bool _hasUserEditedDescription = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectIssueChip(String issueKey) {
    setState(() {
      // If switching to a different chip and user hasn't manually edited
      if (selectedIssue != issueKey) {
        if (!_hasUserEditedDescription) {
          // Auto-fill with the translated chip text
          _descriptionController.text = Utils.getTranslatedLabel(issueKey);
        }
      }
      selectedIssue = issueKey;
    });
  }

  void _onDescriptionChanged(String value) {
    // Track if user has manually edited the description
    if (selectedIssue != null &&
        value != Utils.getTranslatedLabel(selectedIssue!)) {
      _hasUserEditedDescription = true;
    }
  }

  bool _validateInputs() {
    if (selectedIssue == null || selectedIssue!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Utils.getTranslatedLabel(pleaseSelectIssueTypeKey),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Utils.getTranslatedLabel(pleaseEnterDescriptionKey),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    return true;
  }

  void _submitReport() {
    if (_validateInputs()) {
      context.read<TripReportCubit>().submitReport(
            tripId: widget.tripId,
            description: _descriptionController.text.trim(),
            pickupPointId: widget.lastReachedStopId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight * 0.75;

        return Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            padding: EdgeInsets.only(bottom: keyboardHeight),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDescription(),
                        const SizedBox(height: 20),
                        _buildIssueChips(),
                        const SizedBox(height: 20),
                        _buildDescriptionTextField(),
                        const SizedBox(height: 20),
                        _buildSubmitButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Utils.getTranslatedLabel(reportIssuesKey),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      Utils.getTranslatedLabel(reportDelaysPassengersKey),
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.4,
      ),
    );
  }

  Widget _buildIssueChips() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        // Calculate item width: 2 items per row with spacing
        final itemWidth = (screenWidth - 8) / 2;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: driverReportIssueLabels.map((issueKey) {
            final isSelected = selectedIssue == issueKey;
            return SizedBox(
              width: itemWidth,
              height: 44, // Fixed height for consistent layout
              child: GestureDetector(
                onTap: () => _selectIssueChip(issueKey),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    Utils.getTranslatedLabel(issueKey),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDescriptionTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _descriptionController,
          onChanged: _onDescriptionChanged,
          maxLines: 4,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: Utils.getTranslatedLabel(writeIssueKey),
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<TripReportCubit, TripReportState>(
      builder: (context, state) {
        final isSubmitting = state is TripReportSubmitting;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              disabledBackgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    Utils.getTranslatedLabel(submitKey),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
