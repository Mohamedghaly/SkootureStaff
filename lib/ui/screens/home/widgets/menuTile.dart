import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuTile extends StatelessWidget {
  final String titleKey;
  final String? iconImageName;
  final IconData? iconData;
  final Function onTap;
  final double? iconPadding;
  final Widget? trailingWidget;
  const MenuTile(
      {super.key,
      this.iconImageName,
      this.iconData,
      required this.onTap,
      required this.titleKey,
      this.iconPadding,
      this.trailingWidget})
      : assert(iconImageName != null || iconData != null,
            'Either iconImageName or iconData must be provided.'),
        assert(iconImageName == null || iconData == null,
            'Provide only one of iconImageName or iconData.');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          onTap.call();
        },
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.all(iconPadding ?? 15),
              child: iconData != null
                  ? Icon(
                      iconData,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    )
                  : SvgPicture.asset(
                      Utils.getImagePath(iconImageName!),
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn),
                    ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: CustomTextContainer(
                textKey: titleKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
            ),
            trailingWidget ??
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  child: Icon(
                    Directionality.of(context).name == TextDirection.rtl.name
                        ? CupertinoIcons.arrow_left
                        : CupertinoIcons.arrow_right,
                    size: 17.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
          ],
        ),
      ),
    );
  }
}
