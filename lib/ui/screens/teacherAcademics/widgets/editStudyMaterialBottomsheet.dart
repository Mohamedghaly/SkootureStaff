import 'package:eschool_saas_staff/cubits/teacherAcademics/updateStudyMaterialCubit.dart';
import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class EditStudyMaterialBottomSheet extends StatefulWidget {
  final StudyMaterial studyMaterial;
  const EditStudyMaterialBottomSheet({super.key, required this.studyMaterial});

  @override
  State<EditStudyMaterialBottomSheet> createState() =>
      _EditStudyMaterialBottomSheetState();
}

class _EditStudyMaterialBottomSheetState
    extends State<EditStudyMaterialBottomSheet> {
  late final TextEditingController _studyMaterialNameEditingController =
      TextEditingController(text: widget.studyMaterial.fileName);

  late final TextEditingController _youtubeLinkEditingController =
      TextEditingController(
    text:
        widget.studyMaterial.studyMaterialType == StudyMaterialType.youtubeVideo
            ? widget.studyMaterial.fileUrl
            : null,
  );

  late final TextEditingController _otherLinkEditingController =
      TextEditingController(
    text: widget.studyMaterial.studyMaterialType == StudyMaterialType.otherLink
        ? widget.studyMaterial.fileUrl
        : null,
  );

  PlatformFile? addedFile; //if studymaterial type is fileUpload
  PlatformFile?
      addedVideoThumbnailFile; //if studymaterial type is not fileUpload
  PlatformFile? addedVideoFile; //if studymaterial type is videoUpload

  void showErrorMessage(String messageKey) {
    Utils.showSnackBar(
      context: context,
      message: Utils.getTranslatedLabel(messageKey),
    );
  }

  Future<void> editStudyMaterial() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_studyMaterialNameEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterStudyMaterialNameKey);
      return;
    }

    if (widget.studyMaterial.studyMaterialType ==
            StudyMaterialType.youtubeVideo &&
        (_youtubeLinkEditingController.text.trim().isEmpty ||
            !Uri.parse(_youtubeLinkEditingController.text.trim()).isAbsolute)) {
      showErrorMessage(pleaseEnterYoutubeLinkKey);
      return;
    }

    final pickedStudyMaterialTypeId = getStudyMaterialIdByEnum(
      widget.studyMaterial.studyMaterialType,
    );

    final pickedStudyMaterial = PickedStudyMaterial(
      fileName: _studyMaterialNameEditingController.text.trim(),
      pickedStudyMaterialTypeId: pickedStudyMaterialTypeId,
      studyMaterialFile:
          pickedStudyMaterialTypeId == 1 ? addedFile : addedVideoFile,
      videoThumbnailFile: addedVideoThumbnailFile,
      youTubeLink: _youtubeLinkEditingController.text.trim(),
    );

    context.read<UpdateStudyMaterialCubit>().updateStudyMaterial(
          fileId: widget.studyMaterial.id,
          pickedStudyMaterial: pickedStudyMaterial,
        );
  }

  Widget _buildAddedFileContainer(PlatformFile file, Function onTap) {
    return CustomFileContainer(
        title: file.name,
        onDelete: () {
          onTap();
        });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey: editStudyMaterialKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: appContentHorizontalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              CustomTextContainer(
                textKey: oldFilesWillBeReplacedWithLatestOneKey,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).extension<CustomColors>()!.redColor!,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              //Study material type dropdown list
              CustomSelectionDropdownSelectionButton(
                titleKey: getStudyMaterialTypeLabelKeyByEnum(
                  widget.studyMaterial.studyMaterialType,
                ),
                onTap: () {},
                isDisabled: true,
              ),
              const SizedBox(
                height: 15,
              ),
              CustomTextFieldContainer(
                hintTextKey: Utils.getTranslatedLabel(
                  studyMaterialNameKey,
                ),
                maxLines: 1,
                textEditingController: _studyMaterialNameEditingController,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),

              //
              //if file or images has been picked then show the pickedFile name and remove button
              //else show file picker option
              //
              addedFile != null
                  ? _buildAddedFileContainer(addedFile!, () {
                      addedFile = null;
                      setState(() {});
                    })
                  : addedVideoThumbnailFile != null
                      ? _buildAddedFileContainer(addedVideoThumbnailFile!, () {
                          addedVideoThumbnailFile = null;
                          setState(() {});
                        })
                      : UploadImageOrFileButton(
                          uploadFile: true,
                          onTap: () async {
                            final pickedFile = await Utils.openFilePicker(
                              context: context,
                              type: widget.studyMaterial.studyMaterialType ==
                                      StudyMaterialType.file
                                  ? FileType.any
                                  : FileType.image,
                              allowMultiple: false,
                            );

                            if (pickedFile != null) {
                              //if current selected study material type is file
                              if (widget.studyMaterial.studyMaterialType ==
                                  StudyMaterialType.file) {
                                addedFile = pickedFile.files.first;
                              } else {
                                addedVideoThumbnailFile =
                                    pickedFile.files.first;
                              }
                              setState(() {});
                            }
                          },
                          customTitleKey:
                              widget.studyMaterial.studyMaterialType ==
                                      StudyMaterialType.file
                                  ? selectFileKey
                                  : selectThumbnailKey),
              const SizedBox(
                height: 15,
              ),
              widget.studyMaterial.studyMaterialType ==
                      StudyMaterialType.otherLink
                  ? CustomTextFieldContainer(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      hintTextKey: otherLinkKey,
                      maxLines: 2,
                      bottomPadding: 0,
                      textEditingController: _otherLinkEditingController,
                    )
                  : widget.studyMaterial.studyMaterialType ==
                          StudyMaterialType.youtubeVideo
                      ? CustomTextFieldContainer(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          hintTextKey: youtubeLinkKey,
                          maxLines: 2,
                          bottomPadding: 0,
                          textEditingController: _youtubeLinkEditingController,
                        )
                      : widget.studyMaterial.studyMaterialType ==
                              StudyMaterialType.uploadedVideoUrl
                          ? addedVideoFile != null
                              ? _buildAddedFileContainer(addedVideoFile!, () {
                                  addedVideoFile = null;
                                  setState(() {});
                                })
                              : UploadImageOrFileButton(
                                  uploadFile: true,
                                  onTap: () async {
                                    final pickedFile =
                                        await Utils.openFilePicker(
                                      context: context,
                                      type: FileType.video,
                                      allowMultiple: false,
                                    );

                                    if (pickedFile != null) {
                                      addedVideoFile = pickedFile.files.first;
                                      setState(() {});
                                    }
                                  },
                                  customTitleKey:
                                      widget.studyMaterial.studyMaterialType ==
                                              StudyMaterialType.file
                                          ? selectFileKey
                                          : selectVideoKey,
                                )
                          : const SizedBox(),
              const SizedBox(
                height: 15,
              ),
              BlocConsumer<UpdateStudyMaterialCubit, UpdateStudyMaterialState>(
                listener: (context, state) {
                  if (state is UpdateStudyMaterialSuccess) {
                    Get.back(result: state.studyMaterial);
                  } else if (state is UpdateStudyMaterialFailure) {
                    Utils.showSnackBar(
                      context: context,
                      message: state.errorMessage,
                    );
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: () {
                      if (state is UpdateStudyMaterialInProgress) {
                        return;
                      }
                      editStudyMaterial();
                    },
                    widthPercentage: 0.9,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: Utils.getTranslatedLabel(submitKey),
                    showBorder: false,
                    child: state is UpdateStudyMaterialInProgress
                        ? const CustomCircularProgressIndicator(
                            strokeWidth: 2,
                            widthAndHeight: 20,
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
