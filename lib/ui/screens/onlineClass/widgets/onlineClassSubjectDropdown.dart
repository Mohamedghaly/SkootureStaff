import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassSubjectOption.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionTile.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Full-width subject selector used on the create / edit form.
///
/// Opens a bottom sheet listing the available class-subjects. Unlike the list
/// filter, this has no "All" option — a concrete subject must be chosen.
class OnlineClassSubjectDropdown extends StatelessWidget {
  final List<OnlineClassSubjectOption> subjects;
  final OnlineClassSubjectOption? selectedSubject;
  final ValueChanged<OnlineClassSubjectOption> onSelected;

  const OnlineClassSubjectDropdown({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSelected,
  });

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomBottomsheet(
        titleLabelKey: Utils.getTranslatedLabel(selectSubjectKey),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ...subjects.map(
              (subject) => FilterSelectionTile(
                title: subject.label,
                isSelected: selectedSubject?.id == subject.id,
                onTap: () {
                  onSelected(subject);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final isPlaceholder = selectedSubject == null;
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: Container(
        width: double.maxFinite,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedSubject?.label ??
                    Utils.getTranslatedLabel(selectSubjectKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: isPlaceholder
                      ? secondary.withValues(alpha: 0.6)
                      : secondary,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: secondary),
          ],
        ),
      ),
    );
  }
}
