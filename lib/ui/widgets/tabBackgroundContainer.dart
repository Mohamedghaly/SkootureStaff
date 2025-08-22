import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class TabBackgroundContainer extends StatelessWidget {
  final Widget child;
  const TabBackgroundContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ))),
      child: child,
    );
  }
}
