import 'package:eschool_saas_staff/data/models/bottomNavItem.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavItemContainer extends StatelessWidget {
  final int selectedBottomNavIndex;
  final int index;
  final Function(int) onTap;
  final BottomNavItem bottomNavItem;

  const BottomNavItemContainer({
    super.key,
    required this.index,
    required this.bottomNavItem,
    required this.onTap,
    required this.selectedBottomNavIndex,
  });

  bool get isSelected => index == selectedBottomNavIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call(index);
      },
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2.5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: isSelected
                      ? Theme.of(context).colorScheme.surface
                      : null),
              child: SizedBox(
                height: 30,
                child: SvgPicture.asset(Utils.getImagePath(isSelected
                    ? bottomNavItem.selectedIconPath
                    : bottomNavItem.iconPath)),
              ),
            ),
            const SizedBox(height: 5),
            CustomTextContainer(
              textKey: bottomNavItem.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: isSelected ? 1.0 : 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
