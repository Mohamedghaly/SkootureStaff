import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContentTitleWithViewMoreButton extends StatelessWidget {
  final String contentTitleKey;
  final bool? showViewMoreButton;
  final Function? viewMoreOnTap;
  const ContentTitleWithViewMoreButton(
      {super.key,
      required this.contentTitleKey,
      this.showViewMoreButton,
      this.viewMoreOnTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      child: Row(
        children: [
          CustomTextContainer(
            textKey: contentTitleKey,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          (showViewMoreButton ?? false)
              ? GestureDetector(
                  onTap: () {
                    viewMoreOnTap?.call();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent)),
                      child: Row(
                        children: [
                          CustomTextContainer(
                            textKey: viewMoreKey,
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.76)),
                          ),
                          const SizedBox(
                            width: 2.5,
                          ),
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
                      )),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
