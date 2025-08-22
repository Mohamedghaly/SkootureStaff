import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/deleteStudyMaterialCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/updateStudyMaterialCubit.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/confirmDeleteDialog.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/editStudyMaterialBottomsheet.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudyMaterialContainer extends StatelessWidget {
  final bool showEditAndDeleteButton;
  final bool showOnlyStudyMaterialTitles;
  final StudyMaterial studyMaterial;
  final Function(int)? onDeleteStudyMaterial;
  final Function(StudyMaterial)? onEditStudyMaterial;

  const StudyMaterialContainer({
    super.key,
    this.onDeleteStudyMaterial,
    this.onEditStudyMaterial,
    required this.studyMaterial,
    required this.showEditAndDeleteButton,
    this.showOnlyStudyMaterialTitles = false,
  });

  Widget _titleDescriptionRichText(
      {required String title, required String description}) {
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
    return BlocProvider(
      create: (context) => DeleteStudyMaterialCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<DeleteStudyMaterialCubit,
              DeleteStudyMaterialState>(
            listener: (context, state) {
              if (state is DeleteStudyMaterialSuccess) {
                onDeleteStudyMaterial?.call(studyMaterial.id);
              } else if (state is DeleteStudyMaterialFailure) {
                Utils.showSnackBar(
                  context: context,
                  message: Utils.getTranslatedLabel(unableToDeleteKey),
                );
              }
            },
            builder: (context, state) {
              return Opacity(
                opacity: state is DeleteStudyMaterialInProgress ? 0.5 : 1.0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .totalStaffOverviewBackgroundColor!
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextContainer(
                              maxLines: showOnlyStudyMaterialTitles ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              textKey: studyMaterial.fileName,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!showOnlyStudyMaterialTitles ||
                                studyMaterial.studyMaterialType ==
                                    StudyMaterialType.otherLink) ...[
                              const SizedBox(
                                height: 2,
                              ),
                              studyMaterial.studyMaterialType !=
                                          StudyMaterialType.youtubeVideo &&
                                      studyMaterial.studyMaterialType !=
                                          StudyMaterialType.otherLink
                                  ? GestureDetector(
                                      onTap: () {
                                        Utils.viewOrDownloadStudyMaterial(
                                            context: context,
                                            storeInExternalStorage: true,
                                            studyMaterial: studyMaterial);
                                      },
                                      child: _titleDescriptionRichText(
                                          title: Utils.getTranslatedLabel(
                                              filePathKey),
                                          description:
                                              "${studyMaterial.fileName}.${studyMaterial.fileExtension}"))
                                  : const SizedBox(),
                              studyMaterial.studyMaterialType ==
                                          StudyMaterialType.youtubeVideo ||
                                      studyMaterial.studyMaterialType ==
                                          StudyMaterialType.otherLink
                                  ? GestureDetector(
                                      onTap: () {
                                        Utils.viewOrDownloadStudyMaterial(
                                            context: context,
                                            storeInExternalStorage: true,
                                            studyMaterial: studyMaterial);
                                      },
                                      child: _titleDescriptionRichText(
                                          title: Utils.getTranslatedLabel(
                                              studyMaterial.studyMaterialType ==
                                                      StudyMaterialType
                                                          .youtubeVideo
                                                  ? youtubeLinkKey
                                                  : otherLinkKey),
                                          description: studyMaterial.fileUrl))
                                  : const SizedBox(),
                              studyMaterial.studyMaterialType !=
                                          StudyMaterialType.file &&
                                      !showOnlyStudyMaterialTitles
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _titleDescriptionRichText(
                                            title: Utils.getTranslatedLabel(
                                                thumbnailImageKey),
                                            description: ""),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          width: 100,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                studyMaterial.fileThumbnail,
                                              ),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (showEditAndDeleteButton) ...[
                        if (onEditStudyMaterial != null)
                          GestureDetector(
                            onTap: () {
                              if (state is DeleteStudyMaterialInProgress) {
                                return;
                              }
                              Utils.showBottomSheet(
                                child: BlocProvider(
                                  create: (context) =>
                                      UpdateStudyMaterialCubit(),
                                  child: EditStudyMaterialBottomSheet(
                                    studyMaterial: studyMaterial,
                                  ),
                                ),
                                context: context,
                              ).then((value) {
                                if (value != null) {
                                  onEditStudyMaterial
                                      ?.call(value as StudyMaterial);
                                }
                              });
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
                          width: 10,
                        ),
                        if (onDeleteStudyMaterial != null)
                          GestureDetector(
                            onTap: () {
                              if (state is DeleteStudyMaterialInProgress) {
                                return;
                              }
                              showDialog<bool>(
                                context: context,
                                builder: (_) => const ConfirmDeleteDialog(),
                              ).then((value) {
                                if (value != null && value) {
                                  if (context.mounted) {
                                    context
                                        .read<DeleteStudyMaterialCubit>()
                                        .deleteStudyMaterial(
                                          fileId: studyMaterial.id,
                                        );
                                  }
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .extension<CustomColors>()!
                                    .redColor!,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                      ] else ...[
                        GestureDetector(
                          onTap: () {
                            Utils.viewOrDownloadStudyMaterial(
                                context: context,
                                storeInExternalStorage: true,
                                studyMaterial: studyMaterial);
                          },
                          child: Tooltip(
                            message: studyMaterial.studyMaterialType ==
                                    StudyMaterialType.youtubeVideo
                                ? "Play"
                                : studyMaterial.studyMaterialType ==
                                        StudyMaterialType.otherLink
                                    ? "Link"
                                    : "Download",
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .extension<CustomColors>()!
                                  .totalStaffOverviewBackgroundColor!,
                              child: Icon(
                                studyMaterial.studyMaterialType ==
                                        StudyMaterialType.youtubeVideo
                                    ? Icons.play_arrow
                                    : studyMaterial.studyMaterialType ==
                                            StudyMaterialType.otherLink
                                        ? Icons.link
                                        : Icons.download,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
