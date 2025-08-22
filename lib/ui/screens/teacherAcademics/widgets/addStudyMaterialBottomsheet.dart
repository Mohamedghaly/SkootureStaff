import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddStudyMaterialBottomsheet extends StatefulWidget {
  final Function(PickedStudyMaterial) onTapSubmit;
  final bool editFileDetails;
  final PickedStudyMaterial? pickedStudyMaterial;

  const AddStudyMaterialBottomsheet({
    super.key,
    required this.editFileDetails,
    required this.onTapSubmit,
    this.pickedStudyMaterial,
  });

  @override
  State<AddStudyMaterialBottomsheet> createState() =>
      _AddStudyMaterialBottomsheetState();
}

class _AddStudyMaterialBottomsheetState
    extends State<AddStudyMaterialBottomsheet> {
  StudyMaterialTypeItem _selectedStudyMaterial =
      allStudyMaterialTypeItems.first;

  late final TextEditingController _fileNameEditingController =
      TextEditingController();

  late final TextEditingController _youtubeLinkEditingController =
      TextEditingController();

  late final TextEditingController _otherLinkEditingController =
      TextEditingController();
  PlatformFile? addedFile;
  PlatformFile? addedVideoThumbnailFile;
  PlatformFile? addedVideoFile;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.editFileDetails) {
        _fileNameEditingController.text = widget.pickedStudyMaterial!.fileName;

        if (widget.pickedStudyMaterial!.pickedStudyMaterialTypeId == 1) {
          _selectedStudyMaterial = allStudyMaterialTypeItems.firstWhereOrNull(
                  (element) =>
                      element.studyMaterialType == StudyMaterialType.file) ??
              allStudyMaterialTypeItems.first;
          addedFile = widget.pickedStudyMaterial!.studyMaterialFile;
        } else if (widget.pickedStudyMaterial!.pickedStudyMaterialTypeId == 2) {
          _selectedStudyMaterial = allStudyMaterialTypeItems.firstWhereOrNull(
                  (element) =>
                      element.studyMaterialType ==
                      StudyMaterialType.youtubeVideo) ??
              allStudyMaterialTypeItems.first;
          addedVideoThumbnailFile =
              widget.pickedStudyMaterial!.videoThumbnailFile;
          _youtubeLinkEditingController.text =
              widget.pickedStudyMaterial!.youTubeLink ?? "";
        } else if (widget.pickedStudyMaterial!.pickedStudyMaterialTypeId == 4) {
          _selectedStudyMaterial = allStudyMaterialTypeItems.firstWhereOrNull(
                  (element) =>
                      element.studyMaterialType ==
                      StudyMaterialType.otherLink) ??
              allStudyMaterialTypeItems.first;
          _otherLinkEditingController.text =
              widget.pickedStudyMaterial!.otherLink ?? "";
        } else if (widget.pickedStudyMaterial!.pickedStudyMaterialTypeId == 3) {
          _selectedStudyMaterial = allStudyMaterialTypeItems.firstWhereOrNull(
                  (element) =>
                      element.studyMaterialType ==
                      StudyMaterialType.uploadedVideoUrl) ??
              allStudyMaterialTypeItems.first;
          addedVideoThumbnailFile =
              widget.pickedStudyMaterial!.videoThumbnailFile;
          addedVideoFile = widget.pickedStudyMaterial!.studyMaterialFile;
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fileNameEditingController.dispose();
    _youtubeLinkEditingController.dispose();
    _otherLinkEditingController.dispose();
    super.dispose();
  }

  void showErrorMessage(String messageKey) {
    Utils.showSnackBar(
      context: context,
      message: Utils.getTranslatedLabel(messageKey),
    );
  }

  void addStudyMaterial() {
    FocusManager.instance.primaryFocus?.unfocus();
    final pickedStudyMaterialId = _selectedStudyMaterial.id;

    if (_fileNameEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterStudyMaterialNameKey);
      return;
    }

    if (pickedStudyMaterialId == 1 && addedFile == null) {
      showErrorMessage(pleaseSelectFileKey);
      return;
    }

    if (pickedStudyMaterialId != 1 && addedVideoThumbnailFile == null) {
      showErrorMessage(pleaseSelectThumbnailImageKey);
      return;
    }

    if (pickedStudyMaterialId == 2 &&
        (_youtubeLinkEditingController.text.trim().isEmpty ||
            !Uri.parse(_youtubeLinkEditingController.text.trim()).isAbsolute)) {
      showErrorMessage(pleaseEnterYoutubeLinkKey);
      return;
    }
    if (pickedStudyMaterialId == 3 && addedVideoFile == null) {
      showErrorMessage(pleaseSelectVideoKey);
      return;
    }

    if (pickedStudyMaterialId == 4 &&
        _otherLinkEditingController.text.trim().isEmpty) {
      showErrorMessage(pleaseEnterOtherLinkKey);
      return;
    }

    widget.onTapSubmit(
      PickedStudyMaterial(
        fileName: _fileNameEditingController.text.trim(),
        pickedStudyMaterialTypeId: pickedStudyMaterialId,
        studyMaterialFile:
            pickedStudyMaterialId == 1 ? addedFile : addedVideoFile,
        videoThumbnailFile: addedVideoThumbnailFile,
        youTubeLink: pickedStudyMaterialId == 2
            ? _youtubeLinkEditingController.text.trim()
            : '',
        otherLink: pickedStudyMaterialId == 4
            ? _otherLinkEditingController.text.trim()
            : '',
      ),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey: addStudyMaterialKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: appContentHorizontalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 15,
              ),
              CustomSelectionDropdownSelectionButton(
                onTap: () {
                  Utils.showBottomSheet(
                      child: FilterSelectionBottomsheet<StudyMaterialTypeItem>(
                        selectedValue: _selectedStudyMaterial,
                        showFilterByLabel: false,
                        titleKey: studyMaterialTypeKey,
                        values: allStudyMaterialTypeItems,
                        onSelection: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStudyMaterial = value;

                              addedFile = null;
                              addedVideoFile = null;
                              addedVideoThumbnailFile = null;

                              _fileNameEditingController.clear();
                              _youtubeLinkEditingController.clear();
                              _otherLinkEditingController.clear();
                            });
                          }
                          Get.back();
                        },
                      ),
                      context: context);
                },
                titleKey: _selectedStudyMaterial.title,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              const SizedBox(
                height: 15,
              ),
              CustomTextFieldContainer(
                hintTextKey: Utils.getTranslatedLabel(studyMaterialNameKey),
                maxLines: 1,
                textEditingController: _fileNameEditingController,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              addedFile != null
                  ? CustomFileContainer(
                      title: addedFile?.name ?? "",
                      onDelete: () {
                        addedFile = null;
                        setState(() {});
                      },
                    )
                  : addedVideoThumbnailFile != null
                      ? CustomFileContainer(
                          title: addedVideoThumbnailFile?.name ?? "",
                          onDelete: () {
                            addedVideoThumbnailFile = null;
                            setState(() {});
                          },
                        )
                      : UploadImageOrFileButton(
                          uploadFile: true,
                          customTitleKey:
                              _selectedStudyMaterial.studyMaterialType ==
                                      StudyMaterialType.file
                                  ? selectFileKey
                                  : selectThumbnailKey,
                          onTap: () async {
                            final pickedFile = await Utils.openFilePicker(
                                context: context,
                                type:
                                    _selectedStudyMaterial.studyMaterialType ==
                                            StudyMaterialType.file
                                        ? FileType.any
                                        : FileType.image,
                                allowMultiple: false);

                            if (pickedFile != null) {
                              if (context.mounted &&
                                  _selectedStudyMaterial.studyMaterialType ==
                                      StudyMaterialType.file) {
                                addedFile = pickedFile.files.first;
                              } else {
                                addedVideoThumbnailFile =
                                    pickedFile.files.first;
                              }
                              setState(() {});
                            }
                          },
                        ),
              const SizedBox(height: 15),
              if (_selectedStudyMaterial.studyMaterialType ==
                  StudyMaterialType.youtubeVideo)
                CustomTextFieldContainer(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  hintTextKey: youtubeLinkKey,
                  maxLines: 2,
                  bottomPadding: 0,
                  textEditingController: _youtubeLinkEditingController,
                )
              else if (_selectedStudyMaterial.studyMaterialType ==
                  StudyMaterialType.otherLink)
                CustomTextFieldContainer(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  hintTextKey: otherLinkKey,
                  maxLines: 2,
                  bottomPadding: 0,
                  textEditingController: _otherLinkEditingController,
                )
              else if (_selectedStudyMaterial.studyMaterialType ==
                      StudyMaterialType.uploadedVideoUrl &&
                  addedVideoFile != null)
                CustomFileContainer(
                  onDelete: () {
                    addedVideoFile = null;
                    setState(() {});
                  },
                  title: addedVideoFile?.name ?? "",
                )
              else if (_selectedStudyMaterial.studyMaterialType ==
                  StudyMaterialType.uploadedVideoUrl)
                UploadImageOrFileButton(
                  uploadFile: true,
                  customTitleKey: selectVideoKey,
                  onTap: () async {
                    final pickedFile = await Utils.openFilePicker(
                        context: context,
                        type: FileType.video,
                        allowMultiple: false);

                    if (pickedFile != null) {
                      addedVideoFile = pickedFile.files.first;
                      setState(() {});
                    }
                  },
                ),
              const SizedBox(height: 15),
              CustomRoundedButton(
                onTap: addStudyMaterial,
                widthPercentage: 0.9,
                backgroundColor: Theme.of(context).colorScheme.primary,
                buttonTitle: Utils.getTranslatedLabel(submitKey),
                showBorder: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
