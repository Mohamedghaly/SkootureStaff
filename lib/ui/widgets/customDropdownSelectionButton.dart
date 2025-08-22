import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomSelectionDropdownSelectionButton extends StatelessWidget {
  final Function onTap;
  final String titleKey;
  final Color? backgroundColor;
  final bool isDisabled;
  const CustomSelectionDropdownSelectionButton(
      {super.key,
      required this.onTap,
      required this.titleKey,
      this.backgroundColor,
      this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isDisabled) {
          return;
        }
        onTap.call();
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomTextContainer(
                textKey: titleKey,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    fontSize: 15.0,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.76)),
              ),
            ),
            if (!isDisabled) const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }
}
