import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomTabContainer extends StatelessWidget {
  final String titleKey;
  final Function(String) onTap;
  final double width;
  final bool isSelected;
  const CustomTabContainer(
      {super.key,
      required this.titleKey,
      required this.isSelected,
      required this.width,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          return;
        }

        onTap.call(titleKey);
      },
      child: AnimatedContainer(
        duration: tabDuration,
        width: width,
        height: double.maxFinite,
        decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: isSelected ? 1.0 : 0.0),
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(8.0)),
        alignment: Alignment.center,
        child: CustomTextContainer(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textKey: titleKey,
          style: TextStyle(
              color: isSelected
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).colorScheme.secondary,
              fontSize: 15.0,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
