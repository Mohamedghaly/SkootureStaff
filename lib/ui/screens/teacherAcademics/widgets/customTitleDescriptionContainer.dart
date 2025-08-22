import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/readMoreTextContainer.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class CustomTitleDescriptionContainer extends StatelessWidget {
  final String titleKey;
  final String description;
  final Widget? customDescriptionWidget;
  final bool useReadMoreForDescription;
  const CustomTitleDescriptionContainer(
      {super.key,
      required this.titleKey,
      required this.description,
      this.useReadMoreForDescription = true,
      this.customDescriptionWidget});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Utils.getTranslatedLabel(titleKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.76),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        customDescriptionWidget != null
            ? customDescriptionWidget!
            : useReadMoreForDescription
                ? ReadMoreTextContainer(
                    text: description,
                    trimLines: 3,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : CustomTextContainer(
                    textKey: description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ],
    );
  }
}
