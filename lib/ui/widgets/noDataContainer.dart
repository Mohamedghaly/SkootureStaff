import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

class noDataContainer extends StatelessWidget {
  final Color? textColor;
  final String titleKey;
  final bool animate;
  const noDataContainer(
      {Key? key, this.textColor, required this.titleKey, this.animate = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.35),
            child: SvgPicture.asset(Utils.getImagePath("fileNotFound.svg")),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              Utils.getTranslatedLabel(titleKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor ?? Theme.of(context).colorScheme.secondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
