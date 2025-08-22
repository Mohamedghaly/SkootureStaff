import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class MenusWithTitleContainer extends StatelessWidget {
  final String title;
  final List<Widget> menus;
  const MenusWithTitleContainer(
      {super.key, required this.menus, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey: title,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 15.0,
          ),
          ...menus
        ],
      ),
    );
  }
}
