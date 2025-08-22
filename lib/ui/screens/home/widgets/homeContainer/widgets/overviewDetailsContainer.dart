import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OverviewDetailsContainer extends StatelessWidget {
  final Color backgroundColor;
  final String titleKey;
  final String value;
  final String iconPath;
  final String bottomButtonTitleKey;
  final Function onTapBottomViewButton;
  const OverviewDetailsContainer({
    super.key,
    required this.backgroundColor,
    required this.titleKey,
    required this.value,
    required this.iconPath,
    required this.bottomButtonTitleKey,
    required this.onTapBottomViewButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 15.0),
      width: 265,
      height: double.maxFinite,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(5)),
                child: SvgPicture.asset(iconPath),
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextContainer(
                    textKey: value,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.w600),
                  ),
                  CustomTextContainer(
                    textKey: titleKey,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.75)),
                  )
                ],
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              onTapBottomViewButton.call();
            },
            child: Container(
              width: double.maxFinite,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  CustomTextContainer(
                    textKey: bottomButtonTitleKey,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.76)),
                  ),
                  const Spacer(),
                  Icon(
                    Utils.isRTLEnabled(context)
                        ? CupertinoIcons.arrow_left
                        : CupertinoIcons.arrow_right,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.76),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
