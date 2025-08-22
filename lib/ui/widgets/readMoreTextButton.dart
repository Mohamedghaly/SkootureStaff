import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class ReadMoreTextButton extends StatelessWidget {
  final Function onTap;
  final TextStyle? textStyle;

  const ReadMoreTextButton({super.key, required this.onTap, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        child: Row(
          children: [
            CustomTextContainer(
              textKey: readMoreKey,
              style: textStyle ??
                  TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}
