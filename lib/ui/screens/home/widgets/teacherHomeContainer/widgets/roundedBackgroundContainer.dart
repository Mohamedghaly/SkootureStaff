import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class RoundedBackgroundContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  const RoundedBackgroundContainer(
      {super.key,
      required this.child,
      this.color,
      this.borderRadius,
      this.padding,
      this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            vertical: appContentHorizontalPadding,
            horizontal: appContentHorizontalPadding,
          ),
      margin: margin ??
          EdgeInsets.symmetric(
              horizontal: appContentHorizontalPadding,
              vertical: appContentHorizontalPadding),
      decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius ?? 10)),
      child: child,
    );
  }
}
