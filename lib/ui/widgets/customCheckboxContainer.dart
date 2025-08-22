import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomCheckboxContainer extends StatelessWidget {
  final String titleKey;
  final Color backgroundColor;
  final bool value;
  final Function(bool? value) onValueChanged;
  const CustomCheckboxContainer(
      {super.key,
      required this.titleKey,
      required this.backgroundColor,
      required this.value,
      required this.onValueChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onValueChanged(!value);
      },
      radius: 5,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsetsDirectional.only(start: appContentHorizontalPadding),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Theme.of(context).colorScheme.tertiary)),
        child: Row(
          children: [
            Expanded(
              child: CustomTextContainer(
                textKey: titleKey,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.76),
                    fontSize: 15.0),
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onValueChanged,
            )
          ],
        ),
      ),
    );
  }
}
