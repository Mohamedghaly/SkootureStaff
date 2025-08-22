import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomBottomsheet extends StatelessWidget {
  final Widget child;
  final String titleLabelKey;

  const CustomBottomsheet(
      {super.key, required this.child, required this.titleLabelKey});

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
          child: CustomTextContainer(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textKey: titleLabelKey,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800),
          ),
        ),
        Container(
          width: double.maxFinite,
          height: 2,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        Flexible(child: SingleChildScrollView(child: child))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * (0.85)),
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
