import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:flutter/material.dart';

class TextWithFadedBackgroundContainer extends StatelessWidget {
  final String titleKey;
  final Color backgroundColor;
  final Color textColor;
  const TextWithFadedBackgroundContainer(
      {super.key,
      required this.backgroundColor,
      required this.textColor,
      required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0), color: backgroundColor),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: CustomTextContainer(
        textKey: titleKey,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
