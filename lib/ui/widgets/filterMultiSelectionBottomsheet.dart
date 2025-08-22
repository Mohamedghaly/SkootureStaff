import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionTile.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class FilterMultiSelectionBottomsheet<T> extends StatelessWidget {
  final List<T> values;
  final Function(List<T>) onSelection; // Callback to notify parent widget
  final List<T> selectedValues; // List of selected items
  final String titleKey;
  final bool showFilterByLabel;

  const FilterMultiSelectionBottomsheet({
    super.key,
    required this.onSelection,
    required this.selectedValues,
    required this.titleKey,
    required this.values,
    this.showFilterByLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey:
          "${showFilterByLabel ? '${Utils.getTranslatedLabel(filterByKey)} : ' : ''}${Utils.getTranslatedLabel(titleKey)}",
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          ...values.map((value) {
            bool isSelected = selectedValues.contains(value);
            return FilterSelectionTile(
              onTap: () {
                List<T> updatedSelection = List.from(selectedValues);
                if (isSelected) {
                  updatedSelection.remove(value); // Deselect item
                } else {
                  updatedSelection.add(value); // Select item
                }
                onSelection(updatedSelection); // Notify parent widget
              },
              isSelected: isSelected,
              title: value.toString(),
            );
          }).toList(),
        ],
      ),
    );
  }
}
