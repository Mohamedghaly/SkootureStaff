import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionTile.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class MultiSelectionValueBottomsheet<T> extends StatefulWidget {
  final List<T> selectedValues;
  final List<T> values;
  final String titleKey;
  const MultiSelectionValueBottomsheet(
      {super.key,
      required this.selectedValues,
      required this.values,
      required this.titleKey});

  @override
  State<MultiSelectionValueBottomsheet> createState() =>
      _MultiSelectionValueBottomsheetState();
}

class _MultiSelectionValueBottomsheetState<T>
    extends State<MultiSelectionValueBottomsheet> {
  late final List<T> _selectedValues = List.from(widget.selectedValues);

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey: Utils.getTranslatedLabel(widget.titleKey),
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          ...widget.values.map((value) => FilterSelectionTile(
              onTap: () {
                if (_selectedValues.contains(value)) {
                  _selectedValues.remove(value);
                } else {
                  _selectedValues.add(value);
                }
                setState(() {});
              },
              isSelected: _selectedValues.contains(value),
              title: value.toString())),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            child: CustomRoundedButton(
              widthPercentage: 1.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: submitKey,
              showBorder: false,
              onTap: () {
                Get.back(result: _selectedValues);
              },
            ),
          ),
        ],
      ),
    );
  }
}
