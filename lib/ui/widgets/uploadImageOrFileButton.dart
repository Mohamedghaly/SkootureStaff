import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class UploadImageOrFileButton extends StatelessWidget {
  final bool uploadFile;
  final bool includeImageFileOnlyAllowedNote;
  final String? customTitleKey;
  final Function()? onTap;
  const UploadImageOrFileButton(
      {super.key,
      required this.uploadFile,
      this.includeImageFileOnlyAllowedNote = false,
      this.customTitleKey,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          radius: 5,
          onTap: onTap,
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(
                horizontal: appContentHorizontalPadding, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
              color: Theme.of(context)
                  .extension<CustomColors>()!
                  .totalStaffOverviewBackgroundColor!
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .extension<CustomColors>()!
                      .totalStaffOverviewBackgroundColor!,
                  radius: 25,
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.surface,
                    size: 20,
                  ),
                ),
                CustomTextContainer(
                  textKey: customTitleKey ??
                      (uploadFile ? uploadFileKey : uploadImageKey),
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .totalStaffOverviewBackgroundColor!),
                )
              ],
            ),
          ),
        ),
        if (includeImageFileOnlyAllowedNote) ...[
          const SizedBox(
            height: 5,
          ),
          CustomTextContainer(
            textKey: onlyImageAndDocumentsAreAllowedNoteKey,
            style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.redColor!,
                fontWeight: FontWeight.bold),
          ),
        ]
      ],
    );
  }
}
