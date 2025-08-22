import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomFileContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Function()? onDelete;
  final Color? backgroundColor;
  const CustomFileContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.onDelete,
    this.backgroundColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      ),
      padding: EdgeInsets.all(appContentHorizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textKey: title,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  CustomTextContainer(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textKey: subtitle ?? "",
                    style: const TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          if (onDelete != null) ...[
            GestureDetector(
              onTap: () {
                onDelete!();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).extension<CustomColors>()!.redColor!,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
