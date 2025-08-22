import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/announcement/teacherAnnouncementsCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/announcement/teacherDeleteAnnouncementCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/teacherAnnouncement.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/teacherAddEditAnnouncementScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/confirmDeleteDialog.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customExpandableContainer.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customTitleDescriptionContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherManageAnnouncementScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => TeacherAnnouncementsCubit(),
      ),
      BlocProvider(
        create: (context) => ClassSectionsAndSubjectsCubit(),
      ),
    ], child: const TeacherManageAnnouncementScreen());
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherManageAnnouncementScreen({super.key});

  @override
  State<TeacherManageAnnouncementScreen> createState() =>
      _TeacherManageAnnouncementScreenState();
}

class _TeacherManageAnnouncementScreenState
    extends State<TeacherManageAnnouncementScreen> {
  List<ClassSection>? _selectedClassSection;
  TeacherSubject? _selectedSubject;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
                teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void changeSelectedClassSection(List<ClassSection>? classSections,
      {bool fetchNewSubjects = true}) {
    if (_selectedClassSection != classSections) {
      _selectedClassSection = classSections;

      if (fetchNewSubjects &&
          _selectedClassSection != null &&
          _selectedClassSection!.isNotEmpty) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getNewSubjectsFromSelectedClassSectionIndex(
                teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0,
                newClassSectionId:
                    _selectedClassSection!.map((e) => e.id ?? 0).toList())
            .then((value) {
          if (mounted) {
            if (context.read<ClassSectionsAndSubjectsCubit>().state
                is ClassSectionsAndSubjectsFetchSuccess) {
              final successState = context
                  .read<ClassSectionsAndSubjectsCubit>()
                  .state as ClassSectionsAndSubjectsFetchSuccess;

              if (successState.subjects.isNotEmpty) {
                changeSelectedTeacherSubject(successState.subjects.first);
              } else {
                changeSelectedTeacherSubject(null);
              }
            }
          }
        });
      }
      setState(() {});
    }
  }

  void scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<TeacherAnnouncementsCubit>().hasMore()) {
        getMoreAnnouncements();
      }
    }
  }

  void changeSelectedTeacherSubject(TeacherSubject? teacherSubject) {
    if (_selectedSubject != teacherSubject) {
      _selectedSubject = teacherSubject;
      setState(() {});
      getAnnouncements();
    }
  }

  void getAnnouncements() {
    if (_selectedSubject != null &&
        _selectedClassSection != null &&
        _selectedClassSection!.isNotEmpty) {
      context.read<TeacherAnnouncementsCubit>().fetchTeacherAnnouncements(
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          classSectionId: _selectedClassSection?.first.id ?? 0);
    }
  }

  void getMoreAnnouncements() {
    if (_selectedSubject != null &&
        _selectedClassSection != null &&
        _selectedClassSection!.isNotEmpty) {
      context.read<TeacherAnnouncementsCubit>().fetchMoreTeacherAnnouncements(
          classSubjectId: _selectedSubject?.classSubjectId ?? 0,
          classSectionId: _selectedClassSection?.first.id ?? 0);
    }
  }

  Widget _buildAnnouncementItem({required TeacherAnnouncement announcement}) {
    return BlocProvider<TeacherDeleteAnnouncementCubit>(
      create: (context) => TeacherDeleteAnnouncementCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<TeacherDeleteAnnouncementCubit,
              TeacherDeleteAnnouncementState>(listener: (context, state) {
            if (state is TeacherDeleteAnnouncementSuccess) {
              context
                  .read<TeacherAnnouncementsCubit>()
                  .deleteTeacherAnnouncement(announcementId: announcement.id);
            } else if (state is TeacherDeleteAnnouncementFailure) {
              Utils.showSnackBar(
                context: context,
                message: deleteAnnouncementFailedKey,
              );
            }
          }, builder: (context, state) {
            return CustomExpandableContainer(
                key: ValueKey(announcement.id),
                contractedContentWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTitleDescriptionContainer(
                        titleKey: descriptionKey,
                        description: announcement.description),
                  ],
                ),
                onDelete: () {
                  if (state is TeacherDeleteAnnouncementInProgress) {
                    return;
                  }
                  showDialog<bool>(
                    context: context,
                    builder: (_) => const ConfirmDeleteDialog(),
                  ).then((value) {
                    if (value != null && value) {
                      if (context.mounted) {
                        context
                            .read<TeacherDeleteAnnouncementCubit>()
                            .deleteAnnouncement(
                              announcementId: announcement.id,
                            );
                      }
                    }
                  });
                },
                isDeleteLoading: state is TeacherDeleteAnnouncementInProgress,
                onEdit: () {
                  Get.toNamed(Routes.teacherAddEditAnnouncementScreen,
                          arguments:
                              TeacherAddEditAnnouncementScreen.buildArguments(
                                  announcement: announcement,
                                  selectedClassSection: _selectedClassSection,
                                  selectedSubject: _selectedSubject))
                      ?.then((value) {
                    if (value != null && value is bool && value) {
                      //re-fetch announcements if they edit or add
                      getAnnouncements();
                    }
                  });
                },
                isStudyMaterialFile: true,
                studyMaterials: announcement.files,
                titleText: announcement.title);
          });
        },
      ),
    );
  }

  Widget _buildAnnouncementList() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
            bottom: 80,
            top: Utils.appContentTopScrollPadding(context: context) + 100),
        child:
            BlocBuilder<TeacherAnnouncementsCubit, TeacherAnnouncementsState>(
          builder: (context, state) {
            if (state is TeacherAnnouncementsFetchSuccess) {
              if (state.announcements.isEmpty) {
                return noDataContainer(titleKey: noAnnouncementsKey);
              }
              return Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                color: Theme.of(context).colorScheme.surface,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    const CustomTextContainer(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textKey: announcementListKey,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ...List.generate(
                      state.announcements.length,
                      (index) => _buildAnnouncementItem(
                          announcement: state.announcements[index]),
                    ),
                  ],
                ),
              );
            } else if (state is TeacherAnnouncementsFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getAnnouncements();
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAddAnnouncementButton() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.all(appContentHorizontalPadding),
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 1, spreadRadius: 1)
          ], color: Theme.of(context).colorScheme.surface),
          width: MediaQuery.of(context).size.width,
          height: 70,
          child: CustomRoundedButton(
            height: 40,
            widthPercentage: 1.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            buttonTitle: addAnnouncementKey,
            showBorder: false,
            onTap: () {
              Get.toNamed(Routes.teacherAddEditAnnouncementScreen,
                      arguments:
                          TeacherAddEditAnnouncementScreen.buildArguments(
                              announcement: null,
                              selectedClassSection: _selectedClassSection,
                              selectedSubject: _selectedSubject))
                  ?.then((value) {
                if (value != null && value is bool && value) {
                  //re-fetch announcements if they edit or add
                  getAnnouncements();
                }
              });
            },
          ),
        ));
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ClassSectionsAndSubjectsCubit,
          ClassSectionsAndSubjectsState>(
        listener: (context, state) {
          if (state is ClassSectionsAndSubjectsFetchSuccess) {
            if (_selectedClassSection == null &&
                state.classSections.isNotEmpty) {
              final firstClassSection = state.classSections.first;

              changeSelectedClassSection([firstClassSection],
                  fetchNewSubjects: false);
            }
            if (_selectedSubject == null && state.subjects.isNotEmpty) {
              changeSelectedTeacherSubject(state.subjects.first);
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: manageAnnouncementKey),
              AppbarFilterBackgroundContainer(
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilterButton(
                        onTap: () {
                          if (state is ClassSectionsAndSubjectsFetchSuccess &&
                              state.classSections.isNotEmpty) {
                            Utils.showBottomSheet(
                              child: FilterSelectionBottomsheet<ClassSection>(
                                onSelection: (value) {
                                  changeSelectedClassSection([value!]);
                                  Get.back();
                                },
                                selectedValue: _selectedClassSection?.first ??
                                    (state.classSections.isNotEmpty
                                        ? state.classSections.first
                                        : null),
                                titleKey: classKey,
                                values: state.classSections,
                              ),
                              context: context,
                            );
                          }
                        },
                        titleKey: _selectedClassSection == null ||
                                _selectedClassSection!.isEmpty
                            ? classKey
                            : (_selectedClassSection!.first.fullName ?? ""),
                        width: boxConstraints.maxWidth * (0.48),
                      ),
                      FilterButton(
                          onTap: () {
                            if (state is ClassSectionsAndSubjectsFetchSuccess &&
                                state.subjects.isNotEmpty) {
                              Utils.showBottomSheet(
                                  child: FilterSelectionBottomsheet<
                                      TeacherSubject>(
                                    selectedValue: _selectedSubject ??
                                        (state.subjects.isNotEmpty
                                            ? state.subjects.first
                                            : null),
                                    titleKey: subjectKey,
                                    values: state.subjects,
                                    onSelection: (value) {
                                      changeSelectedTeacherSubject(value!);
                                      Get.back();
                                    },
                                  ),
                                  context: context);
                            }
                          },
                          titleKey: _selectedSubject?.id == null
                              ? subjectKey
                              : _selectedSubject?.subject
                                      .getSybjectNameWithType() ??
                                  "",
                          width: boxConstraints.maxWidth * (0.48)),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: BlocBuilder<ClassSectionsAndSubjectsCubit,
                ClassSectionsAndSubjectsState>(
              builder: (context, state) {
                if (state is ClassSectionsAndSubjectsFetchSuccess) {
                  if (state.classSections.isEmpty) {
                    return const noDataContainer(titleKey: noClassSectionKey);
                  }
                  if (state.subjects.isEmpty) {
                    return const noDataContainer(titleKey: noSubjectsKey);
                  }
                  return _buildAnnouncementList();
                }

                if (state is ClassSectionsAndSubjectsFetchFailure) {
                  return Center(
                      child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<ClassSectionsAndSubjectsCubit>()
                          .getClassSectionsAndSubjects(
                            teacherId:
                                context.read<AuthCubit>().getUserDetails().id ??
                                    0,
                          );
                    },
                  ));
                }
                if (state is ClassSectionsAndSubjectsFetchSuccess) {
                  if (state.classSections.isEmpty) {
                    return Center(
                      child: noDataContainer(titleKey: noClassSectionKey),
                    );
                  }

                  if (state.subjects.isEmpty) {
                    return Center(
                      child: noDataContainer(titleKey: noSubjectsKey),
                    );
                  }
                }

                if (state is ClassSectionsAndSubjectsInitial) {
                  return Center(
                    child: CustomCircularProgressIndicator(
                      indicatorColor: Theme.of(context).colorScheme.primary,
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
          ),
          SafeArea(child: _buildAddAnnouncementButton()),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}
