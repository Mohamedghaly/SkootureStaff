import 'package:eschool_saas_staff/ui/screens/home/widgets/menuTile.dart';
import 'package:flutter/material.dart';

class CustomMenuTile extends StatelessWidget {
  final String iconImageName;
  final String titleKey;
  final Function onTap;
  const CustomMenuTile(
      {super.key,
      required this.iconImageName,
      required this.titleKey,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MenuTile(
      iconPadding: 10,
      iconImageName: iconImageName,
      titleKey: titleKey,
      onTap: () {
        onTap.call();
      },
    );
  }
}
