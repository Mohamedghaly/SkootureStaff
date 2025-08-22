import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/announcement/editGeneralAnnouncementCubit.dart';
import 'package:eschool_saas_staff/data/models/announcement.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/multiSelectionValueBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class EditAnnouncementScreen extends StatefulWidget {
  final Announcement announcement;
  const EditAnnouncementScreen({super.key, required this.announcement});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
        BlocProvider(
          create: (context) => EditGeneralAnnouncementCubit(),
        ),
      ],
      child: EditAnnouncementScreen(
        announcement: arguments['announcement'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required Announcement announcement}) {
    return {"announcement": announcement};
  }

  @override
  State<EditAnnouncementScreen> createState() => _EditAnnouncementScreenState();
}

class _EditAnnouncementScreenState extends State<EditAnnouncementScreen> {
  List<ClassSection> _selectedClassSections = [];

  late final TextEditingController _titleTextEditingController =
      TextEditingController(text: widget.announcement.title ?? "");
  late final TextEditingController _descriptionTextEditingController =
      TextEditingController(text: widget.announcement.description ?? "");

  final List<PlatformFile> _pickedFiles = [];

  late final List<StudyMaterial> _files = widget.announcement.files ?? [];

  bool refreshAnnouncementsInPreviousPage = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ClassesCubit>().getClasses();
      }
    });
  }

  @override
  void dispose() {
    _titleTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await Utils.openFilePicker(context: context);
    if (result != null) {
      _pickedFiles.addAll(result.files);
      setState(() {});
    }
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        if (state is! ClassesFetchSuccess) {
          return const SizedBox();
        }
        return Align(
            alignment: Alignment.bottomCenter,
            child: BlocConsumer<EditGeneralAnnouncementCubit,
                EditGeneralAnnouncementState>(
              listener: (context, editGeneralAnnouncementState) {
                if (editGeneralAnnouncementState
                    is EditGeneralAnnouncementSuccess) {
                  Get.back();
                  Utils.showSnackBar(
                      message: announcementUpdatedSuccessfullyKey,
                      context: context);
                } else if (editGeneralAnnouncementState
                    is EditGeneralAnnouncementFailure) {
                  Utils.showSnackBar(
                      message: editGeneralAnnouncementState.errorMessage,
                      context: context);
                }
              },
              builder: (context, editGeneralAnnouncementState) {
                return PopScope(
                  canPop: editGeneralAnnouncementState
                      is! EditGeneralAnnouncementInProgress,
                  child: Container(
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    decoration: BoxDecoration(boxShadow: const [
                      BoxShadow(
                          color: Colors.black12, blurRadius: 1, spreadRadius: 1)
                    ], color: Theme.of(context).colorScheme.surface),
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    child: CustomRoundedButton(
                      height: 40,
                      widthPercentage: 1.0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: editKey,
                      showBorder: false,
                      child: editGeneralAnnouncementState
                              is EditGeneralAnnouncementInProgress
                          ? const CustomCircularProgressIndicator()
                          : null,
                      onTap: () {
                        if (editGeneralAnnouncementState
                            is EditGeneralAnnouncementInProgress) {
                          return;
                        }

                        if (_titleTextEditingController.text.trim().isEmpty) {
                          Utils.showSnackBar(
                              message: pleaseEnterTitleKey, context: context);
                          return;
                        }

                        if (_selectedClassSections.isEmpty) {
                          Utils.showSnackBar(
                              message: pleaseSelectAtLeastOneClassKey,
                              context: context);
                          return;
                        }

                        context
                            .read<EditGeneralAnnouncementCubit>()
                            .editGeneralAnnouncement(
                                announcementId: widget.announcement.id ?? 0,
                                description: _descriptionTextEditingController
                                    .text
                                    .trim(),
                                filePaths: _pickedFiles
                                    .map((e) => e.path ?? "")
                                    .toList(),
                                title: _titleTextEditingController.text.trim(),
                                classSectionIds: _selectedClassSections
                                    .map((e) => e.id ?? 0)
                                    .toList());
                      },
                    ),
                  ),
                );
              },
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocConsumer<ClassesCubit, ClassesState>(
          listener: (context, state) {
            if (state is ClassesFetchSuccess) {
              if (context.read<ClassesCubit>().getAllClasses().isNotEmpty) {
                for (var classSection
                    in context.read<ClassesCubit>().getAllClasses()) {
                  final announcementSentToThisClass = widget
                          .announcement.announcementClasses
                          ?.indexWhere((element) =>
                              element.classSectionId == classSection.id) !=
                      -1;
                  if (announcementSentToThisClass) {
                    _selectedClassSections.add(classSection);
                  }
                }
              }
            }
          },
          builder: (context, state) {
            if (state is ClassesFetchSuccess) {
              return Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: 100,
                      left: appContentHorizontalPadding,
                      right: appContentHorizontalPadding,
                      top: Utils.appContentTopScrollPadding(context: context) +
                          20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFieldContainer(
                          textEditingController: _titleTextEditingController,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          hintTextKey: titleKey),
                      CustomTextFieldContainer(
                          textEditingController:
                              _descriptionTextEditingController,
                          maxLines: 5,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          hintTextKey: descriptionKey),
                      CustomSelectionDropdownSelectionButton(
                          onTap: () {
                            Utils.showBottomSheet(
                                    child: MultiSelectionValueBottomsheet<
                                            ClassSection>(
                                        values: context
                                            .read<ClassesCubit>()
                                            .getAllClasses(),
                                        selectedValues:
                                            List.from(_selectedClassSections),
                                        titleKey: titleKey),
                                    context: context)
                                .then((value) {
                              if (value != null) {
                                final classes =
                                    List<ClassSection>.from(value as List);

                                _selectedClassSections =
                                    List<ClassSection>.from(classes);
                                setState(() {});
                              }
                            });
                          },
                          titleKey: classSectionKey),
                      const SizedBox(
                        height: 15,
                      ),
                      Wrap(
                        alignment: WrapAlignment.start,
                        direction: Axis.horizontal,
                        spacing: 10,
                        runSpacing: 10,
                        children: _selectedClassSections
                            .map(
                              (classSection) => Container(
                                padding:
                                    EdgeInsets.all(appContentHorizontalPadding),
                                color: Theme.of(context).colorScheme.surface,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomTextContainer(
                                        textKey: classSection.fullName ?? "-"),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      _files.isEmpty
                          ? const SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextContainer(
                                  textKey: filesKey,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                Column(
                                  children: _files
                                      .map(
                                        (studyMaterial) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 15),
                                          child: StudyMaterialContainer(
                                            onDeleteStudyMaterial: (fileId) {
                                              _files.removeWhere((element) =>
                                                  element.id == fileId);
                                              refreshAnnouncementsInPreviousPage =
                                                  true;
                                              setState(() {});
                                            },
                                            showOnlyStudyMaterialTitles: true,
                                            showEditAndDeleteButton: true,
                                            studyMaterial: studyMaterial,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                      const SizedBox(
                        height: 25,
                      ),
                      UploadImageOrFileButton(
                        uploadFile: true,
                        includeImageFileOnlyAllowedNote: true,
                        onTap: () {
                          _pickFiles();
                        },
                      ),
                      ...List.generate(_pickedFiles.length, (index) => index)
                          .map(
                        (index) => Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: CustomFileContainer(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            onDelete: () {
                              _pickedFiles.removeAt(index);
                              setState(() {});
                            },
                            title: _pickedFiles[index].name,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }

            if (state is ClassesFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<ClassesCubit>().getClasses();
                  },
                ),
              );
            }

            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        _buildSubmitButton(),
        Align(
            alignment: Alignment.topCenter,
            child: CustomAppbar(
              titleKey: editAnnouncementKey,
              onBackButtonTap: () {
                if (context.read<EditGeneralAnnouncementCubit>().state
                    is EditGeneralAnnouncementInProgress) {
                  return;
                }

                Get.back();
              },
            ))
      ],
    ));
  }
}
