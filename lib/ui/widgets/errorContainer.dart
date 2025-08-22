import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ErrorContainer extends StatelessWidget {
  final String errorMessage;
  final bool? showRetryButton;
  final bool? showErrorImage;
  final Color? errorMessageColor;
  final double? errorMessageFontSize;
  final Function? onTapRetry;
  final Color? retryButtonTextColor;

  const ErrorContainer({
    super.key,
    required this.errorMessage,
    this.errorMessageColor,
    this.errorMessageFontSize,
    this.onTapRetry,
    this.showErrorImage,
    this.retryButtonTextColor,
    this.showRetryButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (showErrorImage ?? true)
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * (0.25),
                  child: SvgPicture.asset(Utils.getImagePath("error.svg")),
                )
              : const SizedBox(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CustomTextContainer(
                textKey: errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: errorMessageColor ??
                      Theme.of(context).colorScheme.secondary,
                  fontSize: errorMessageFontSize ?? 16,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          (showRetryButton ?? true)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CupertinoButton(
                      child: CustomTextContainer(
                        textKey: retryKey,
                        style: TextStyle(
                            color: retryButtonTextColor ??
                                Theme.of(context).colorScheme.primary),
                      ),
                      onPressed: () {
                        onTapRetry?.call();
                      }),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
