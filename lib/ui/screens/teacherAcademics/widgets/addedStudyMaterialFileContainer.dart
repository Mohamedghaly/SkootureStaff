import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/addStudyMaterialBottomsheet.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class AddedStudyMaterialContainer extends StatelessWidget {
  final int fileIndex;
  final PickedStudyMaterial file;
  final Function(int, PickedStudyMaterial) onEdit;
  final Function(int) onDelete;
  final Color? backgroundColor;

  const AddedStudyMaterialContainer({
    super.key,
    required this.file,
    required this.fileIndex,
    required this.onDelete,
    required this.onEdit,
    this.backgroundColor,
  });

  Widget _titleDescriptionRichText({
    required String title,
    required String description,
  }) {
    return Text.rich(
      TextSpan(
        text: "$title: ",
        children: [
          TextSpan(
            text: description,
            style:
                const TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
          ),
        ],
        style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      ),
      padding: EdgeInsets.all(appContentHorizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textKey: file.fileName,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                file.pickedStudyMaterialTypeId != 2 &&
                        file.pickedStudyMaterialTypeId != 4
                    ? _titleDescriptionRichText(
                        title: Utils.getTranslatedLabel(filePathKey),
                        description: file.studyMaterialFile?.name ?? "")
                    : const SizedBox.shrink(),
                file.pickedStudyMaterialTypeId == 2
                    ? _titleDescriptionRichText(
                        title: Utils.getTranslatedLabel(youtubeLinkKey),
                        description: file.youTubeLink ?? "")
                    : const SizedBox.shrink(),
                file.pickedStudyMaterialTypeId != 1
                    ? _titleDescriptionRichText(
                        title: Utils.getTranslatedLabel(thumbnailImageKey),
                        description: file.videoThumbnailFile?.name ?? "")
                    : const SizedBox.shrink(),
                file.pickedStudyMaterialTypeId == 4
                    ? _titleDescriptionRichText(
                        title: Utils.getTranslatedLabel(otherLinkKey),
                        description: file.otherLink ?? "")
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Utils.showBottomSheet(
                child: AddStudyMaterialBottomsheet(
                  editFileDetails: true,
                  pickedStudyMaterial: file,
                  onTapSubmit: (updatedFile) {
                    onEdit(fileIndex, updatedFile);
                  },
                ),
                context: context,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          GestureDetector(
            onTap: () {
              onDelete(fileIndex);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).extension<CustomColors>()!.redColor!,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
