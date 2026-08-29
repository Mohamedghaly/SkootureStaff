import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassSubjectOption.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionTile.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// "Subject" label on the left + an `All ▾` dropdown chip on the right that
/// lets the user filter the list by class-subject.
///
/// A `null` selection means "All subjects".
class OnlineClassSubjectFilterBar extends StatelessWidget {
  final List<OnlineClassFilterSubject> subjects;
  final OnlineClassFilterSubject? selectedSubject;
  final ValueChanged<OnlineClassFilterSubject?> onSelected;

  const OnlineClassSubjectFilterBar({
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
        titleLabelKey: Utils.getTranslatedLabel(subjectKey),
        child: Column(
          children: [
            const SizedBox(height: 20),
            FilterSelectionTile(
              title: Utils.getTranslatedLabel(allKey),
              isSelected: selectedSubject == null,
              onTap: () {
                onSelected(null);
                Navigator.of(context).pop();
              },
            ),
            ...subjects.map(
              (subject) => FilterSelectionTile(
                title: subject.name,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: CustomTextContainer(
              textKey: subjectKey,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 24 / 16,
                color: secondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _openPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(color: secondary),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedSubject?.name ?? Utils.getTranslatedLabel(allKey),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: secondary,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20, color: secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
