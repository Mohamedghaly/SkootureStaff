import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomBottomsheet extends StatelessWidget {
  final Widget child;
  final String titleLabelKey;
  final Widget? trailing;

  /// Whether the body scrolls as a whole.
  ///
  /// Turn it off when the child does its own scrolling (a list under a sticky
  /// header, say): the child then gets a bounded height to lay out against
  /// instead of the infinite one a scroll view hands down.
  final bool scrollableChild;

  const CustomBottomsheet(
      {super.key,
      required this.child,
      required this.titleLabelKey,
      this.scrollableChild = true,
      this.trailing});

  Widget _buildContent({required BuildContext context}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 5,
          decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.5)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: 15, horizontal: appContentHorizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textKey: titleLabelKey,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w800),
                ),
              ),
              trailing ?? const SizedBox()
            ],
          ),
        ),
        Container(
          width: double.maxFinite,
          height: 2,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        Flexible(
            child:
                scrollableChild ? SingleChildScrollView(child: child) : child)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // No keyboard padding here on purpose: the bottom sheet route already
    // insets the sheet by `viewInsets.bottom` (see GetX `bottomsheet.dart`).
    // Adding it again would eat the height twice, leaving the body nothing to
    // lay out in.
    return SafeArea(
      // The sheet is anchored to the bottom of the screen, so a status bar
      // inset would only add dead space above the title.
      top: false,
      child: Container(
        width: mediaQuery.size.width,
        // Measured against what the keyboard leaves behind, so an open
        // keyboard shrinks the sheet instead of pushing it off screen.
        constraints: BoxConstraints(
            maxHeight: (mediaQuery.size.height - mediaQuery.viewInsets.bottom) *
                (0.85)),
        padding: EdgeInsets.symmetric(
            vertical: appContentHorizontalPadding * (1.25)),
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(bottomsheetBorderRadius),
                topRight: Radius.circular(bottomsheetBorderRadius))),
        child: _buildContent(context: context),
      ),
    );
  }
}
