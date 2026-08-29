import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/manageDiary/diariesCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/manageDiary/deleteDiaryCubit.dart';
import 'package:eschool_saas_staff/cubits/studentDetailsCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/studentDiaryDetails.dart';
import 'package:eschool_saas_staff/data/models/diaryStudent.dart';
import 'package:eschool_saas_staff/ui/screens/manageDiary/widgets/diaryEntryCard.dart';
import 'package:eschool_saas_staff/ui/screens/manageDiary/widgets/diaryStatsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/sortSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class StudentDiaryScreen extends StatefulWidget {
  final int studentId;

  const StudentDiaryScreen({super.key, required this.studentId});

  static Widget getRouteInstance({required int studentId}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DiariesCubit()),
        BlocProvider(create: (context) => StudentDetailsCubit()),
        BlocProvider(create: (context) => DeleteDiaryCubit()),
      ],
      child: StudentDiaryScreen(studentId: studentId),
    );
  }

  @override
  State<StudentDiaryScreen> createState() => _StudentDiaryScreenState();
}

class _StudentDiaryScreenState extends State<StudentDiaryScreen> {
  String _selectedCategory = "All Categories";
  String _selectedSubject = "All Subjects";
  String _selectedSort = "new"; // Default to newest first
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_scrollListener);

  @override
  void initState() {
    super.initState();
    // Fetch diaries and student details when screen initializes
    Future.delayed(Duration.zero, () {
      context.read<DiariesCubit>().getDiaries(
            sort: _selectedSort,
            studentId: widget.studentId,
          );
      context
          .read<StudentDetailsCubit>()
          .getStudentDetails(studentId: widget.studentId);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<DiariesCubit>().hasMore()) {
        // Get the actual IDs for selected filters
        int? categoryId;
        int? subjectId;

        if (_selectedCategory != "All Categories") {
          categoryId = _getCategoryIdFromName(_selectedCategory);
        }

        if (_selectedSubject != "All Subjects") {
          subjectId = _getSubjectIdFromName(_selectedSubject);
        }

        context.read<DiariesCubit>().fetchMore(
              sort: _selectedSort,
              diaryCategoryId: categoryId,
              subjectId: subjectId,
            );
      }
    }
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _selectedCategory = value ?? "All Categories";
    });
    // Refresh data with new filter
    _refreshData();
  }

  void _onSubjectChanged(String? value) {
    setState(() {
      _selectedSubject = value ?? "All Subjects";
      _selectedCategory = "All Categories";
    });
    // Refresh data with new filter
    _refreshData();
  }

  void _refreshData() {
    // Get the actual IDs for selected filters
    int? categoryId;
    int? subjectId;

    if (_selectedCategory != "All Categories") {
      categoryId = _getCategoryIdFromName(_selectedCategory);
    }

    if (_selectedSubject != "All Subjects") {
      subjectId = _getSubjectIdFromName(_selectedSubject);
    }

    context.read<DiariesCubit>().getDiaries(
          sort: _selectedSort,
          studentId: widget.studentId,
          diaryCategoryId: categoryId,
          subjectId: subjectId,
        );
  }

  void _onSortChanged(String? value) {
    setState(() {
      _selectedSort = value ?? "new";
    });
    // Refresh data with new sort
    _refreshData();
  }

  void _showSortBottomSheet() {
    Utils.showBottomSheet(
      child: SortSelectionBottomsheet(
        selectedValue: _selectedSort,
        onSelection: (value) {
          _onSortChanged(value);
          Get.back();
        },
      ),
      context: context,
    );
  }

  void _onDeleteNote(String noteId) {
    // Show confirmation dialog and delete note
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: CustomTextContainer(
          textKey: deleteNoteKey,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        content: CustomTextContainer(
          textKey: deleteNoteConfirmationKey,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: CustomTextContainer(
              textKey: cancelKey,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog first
              Get.back();

              // Parse the noteId to int and call delete API
              final int diaryId = int.parse(noteId);
              context.read<DeleteDiaryCubit>().deleteDiary(
                    diaryId: diaryId,
                  );
            },
            child: CustomTextContainer(
              textKey: deleteKey,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DiaryStudent> _getFilteredEntries(List<StudentDiaryDetails> students) {
    List<DiaryStudent> allEntries = [];

    for (final student in students) {
      allEntries.addAll(student.diaryStudent);
    }

    return allEntries.where((entry) {
      bool categoryMatch = _selectedCategory == "All Categories" ||
          entry.diary.diaryCategory.name == _selectedCategory;
      bool subjectMatch = _selectedSubject == "All Subjects" ||
          entry.diary.subject?.name == _selectedSubject;
      return categoryMatch && subjectMatch;
    }).toList();
  }

  int _getPositiveCount(List<DiaryStudent> entries) {
    return entries
        .where((entry) => entry.diary.diaryCategory.type == 'positive')
        .length;
  }

  int _getNegativeCount(List<DiaryStudent> entries) {
    return entries
        .where((entry) => entry.diary.diaryCategory.type == 'negative')
        .length;
  }

  Map<String, dynamic> _convertDiaryStudentToEntryMap(
      DiaryStudent diaryStudent) {
    // Check delete permission
    final hasDeletePermission = context
        .read<StaffAllowedPermissionsAndModulesCubit>()
        .isPermissionGiven(permission: deleteStudentDiaryPermissionKey);

    return {
      'id': diaryStudent.diary.id
          .toString(), // Use diary.id instead of diaryStudent.id
      'category': diaryStudent.diary.diaryCategory.name,
      "type": diaryStudent.diary.diaryCategory.type,
      'title': diaryStudent.diary.title ?? 'No description',
      'description': diaryStudent.diary.description ?? 'No description',
      'timestamp': _formatTimestamp(diaryStudent.diary.createdAt),
      'name_with_type': diaryStudent.diary.subject?.nameWithType,
      'subject': diaryStudent.diary.subject?.name,
      'showActions':
          hasDeletePermission, // Show delete action based on permission
    };
  }

  String _formatTimestamp(String createdAt) {
    try {
      // Use the utility method to safely parse the custom date format
      final dateTime = Utils.parseDateSafely(createdAt);

      if (dateTime == null) {
        debugPrint('Failed to parse diary date: $createdAt');
        return 'Unknown time';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      debugPrint('Error formatting diary timestamp: $createdAt - $e');
      return 'Unknown time';
    }
  }

  // Get unique categories from the API data
  List<String> _getCategories(List<StudentDiaryDetails> students) {
    Set<String> categories = {"All Categories"};
    for (final student in students) {
      for (final diaryStudent in student.diaryStudent) {
        categories.add(diaryStudent.diary.diaryCategory.name);
      }
    }
    return categories.toList();
  }

  // Get unique subjects from the student details API
  List<String> _getSubjects() {
    Set<String> subjects = {"All Subjects"};

    // Get subjects from StudentDetailsCubit
    final studentDetailsState = context.read<StudentDetailsCubit>().state;
    if (studentDetailsState is StudentDetailsFetchSuccess) {
      final subjectNames =
          context.read<StudentDetailsCubit>().getSubjectNames();
      subjects.addAll(subjectNames);
    }

    return subjects.toList();
  }

  // Get category ID from category name
  int? _getCategoryIdFromName(String categoryName) {
    final diariesState = context.read<DiariesCubit>().state;
    if (diariesState is DiariesFetchSuccess) {
      for (final student in diariesState.students) {
        for (final diaryStudent in student.diaryStudent) {
          if (diaryStudent.diary.diaryCategory.name == categoryName) {
            return diaryStudent.diary.diaryCategory.id;
          }
        }
      }
    }
    return null;
  }

  // Get subject ID from subject name
  int? _getSubjectIdFromName(String subjectName) {
    final studentDetailsState = context.read<StudentDetailsCubit>().state;
    if (studentDetailsState is StudentDetailsFetchSuccess) {
      final allSubjects = studentDetailsState.studentDetails.getAllSubjects();
      for (final subject in allSubjects) {
        if (subject.name == subjectName) {
          return subject.id;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<DiariesCubit, DiariesState>(
            listener: (context, state) {
              if (state is DiariesFetchFailure) {
                Utils.showSnackBar(
                  context: context,
                  message: state.errorMessage,
                );
              }
            },
          ),
          BlocListener<StudentDetailsCubit, StudentDetailsState>(
            listener: (context, state) {
              if (state is StudentDetailsFetchFailure) {
                Utils.showSnackBar(
                  context: context,
                  message: state.errorMessage,
                );
              }
            },
          ),
          BlocListener<DeleteDiaryCubit, DeleteDiaryState>(
            listener: (context, state) {
              if (state is DeleteDiarySuccess) {
                // Show success message
                Utils.showSnackBar(
                  context: context,
                  message: diaryDeletedSuccessfullyKey,
                );

                // Refresh the diary list after successful deletion
                _refreshData();
              } else if (state is DeleteDiaryFailure) {
                // Show error message
                Utils.showSnackBar(
                  context: context,
                  message: state.errorMessage,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<DiariesCubit, DiariesState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Main Content
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: Utils.appContentTopScrollPadding(context: context) +
                          78,
                    ),
                    child: _buildContent(state),
                  ),
                ),

                // Custom App Bar with back button and filter button
                Align(
                  alignment: Alignment.topCenter,
                  child: CustomAppbar(
                    titleKey: studentDiaryKey,
                    showBackButton: true,
                    onBackButtonTap: () {
                      Get.toNamed(Routes.studentsScreen);
                    },
                    trailingWidget: IconButton(
                      onPressed: _showSortBottomSheet,
                      icon: Icon(
                        Icons.filter_list,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                // Filter Section
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 55 + MediaQuery.of(context).padding.top,
                    ),
                    child: AppbarFilterBackgroundContainer(
                      height: 80,
                      child: LayoutBuilder(
                        builder: (context, boxConstraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FilterButton(
                                onTap: () {
                                  final subjects = _getSubjects();
                                  Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<String>(
                                      onSelection: (value) {
                                        _onSubjectChanged(value);
                                        Get.back();
                                      },
                                      selectedValue: _selectedSubject,
                                      titleKey: "Subjects",
                                      values: subjects,
                                      showFilterByLabel: false,
                                    ),
                                    context: context,
                                  );
                                },
                                titleKey: _selectedSubject,
                                width: boxConstraints.maxWidth * 0.48,
                              ),
                              FilterButton(
                                onTap: () {
                                  if (state is DiariesFetchSuccess) {
                                    final categories =
                                        _getCategories(state.students);
                                    Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<String>(
                                        onSelection: (value) {
                                          _onCategoryChanged(value);
                                          Get.back();
                                        },
                                        selectedValue: _selectedCategory,
                                        titleKey: "Categories",
                                        values: categories,
                                        showFilterByLabel: false,
                                      ),
                                      context: context,
                                    );
                                  }
                                },
                                titleKey: _selectedCategory,
                                width: boxConstraints.maxWidth * 0.48,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(DiariesState state) {
    if (state is DiariesFetchInProgress) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
          child: CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (state is DiariesFetchFailure) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
          child: ErrorContainer(
            errorMessage: state.errorMessage,
            onTapRetry: () {
              // Get the actual IDs for selected filters
              int? categoryId;
              int? subjectId;

              if (_selectedCategory != "All Categories") {
                categoryId = _getCategoryIdFromName(_selectedCategory);
              }

              if (_selectedSubject != "All Subjects") {
                subjectId = _getSubjectIdFromName(_selectedSubject);
              }

              context.read<DiariesCubit>().getDiaries(
                    sort: _selectedSort,
                    studentId: widget.studentId,
                    diaryCategoryId: categoryId,
                    subjectId: subjectId,
                  );
            },
          ),
        ),
      );
    }

    if (state is DiariesFetchSuccess) {
      final filteredEntries = _getFilteredEntries(state.students);
      final positiveCount = _getPositiveCount(filteredEntries);
      final negativeCount = _getNegativeCount(filteredEntries);

      // Check create permission
      final hasCreatePermission = context
          .read<StaffAllowedPermissionsAndModulesCubit>()
          .isPermissionGiven(permission: createStudentDiaryPermissionKey);

      return Column(
        children: [
          // Fixed Content (Statistics and Add Note Button)
          Container(
            padding: EdgeInsets.symmetric(
              vertical: appContentHorizontalPadding,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: _FixedContentWidget(
              positiveCount: positiveCount,
              negativeCount: negativeCount,
              showAddNoteButton: hasCreatePermission,
              onAddNoteTap: () {
                Get.toNamed(Routes.addNoteScreen);
              },
            ),
          ),

          // Scrollable Content (Diary Entries List)
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20, top: 16),
              child: Column(
                children: [
                  // Diary Entries List
                  if (filteredEntries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: noDataContainer(
                        titleKey: "noDiaryEntriesFound",
                      ),
                    )
                  else
                    ...filteredEntries.map((diaryStudent) {
                      final entry =
                          _convertDiaryStudentToEntryMap(diaryStudent);
                      return DiaryEntryCard(
                        entry: entry,
                        onDelete: _onDeleteNote,
                      );
                    }),

                  // Load more indicator
                  if (state.fetchMoreInProgress)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                  // Load more error
                  if (state.fetchMoreError)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CustomTextButton(
                          buttonTextKey: retryKey,
                          onTapButton: () {
                            // Get the actual IDs for selected filters
                            int? categoryId;
                            int? subjectId;

                            if (_selectedCategory != "All Categories") {
                              categoryId =
                                  _getCategoryIdFromName(_selectedCategory);
                            }

                            if (_selectedSubject != "All Subjects") {
                              subjectId =
                                  _getSubjectIdFromName(_selectedSubject);
                            }

                            context.read<DiariesCubit>().fetchMore(
                                  sort: _selectedSort,
                                  diaryCategoryId: categoryId,
                                  subjectId: subjectId,
                                );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }
}

class _FixedContentWidget extends StatelessWidget {
  final int positiveCount;
  final int negativeCount;
  final bool showAddNoteButton;
  final VoidCallback onAddNoteTap;

  const _FixedContentWidget({
    required this.positiveCount,
    required this.negativeCount,
    required this.showAddNoteButton,
    required this.onAddNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      child: Column(
        children: [
          // Statistics Cards
          DiaryStatsContainer(
            positiveCount: positiveCount,
            negativeCount: negativeCount,
          ),

          // Add Note Button - Only show if user has create permission
          if (showAddNoteButton) ...[
            const SizedBox(height: 20),
            CustomRoundedButton(
              onTap: onAddNoteTap,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: addNoteKey,
              showBorder: false,
              widthPercentage: 1.0,
              height: 40,
              radius: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // White circular background with black plus icon
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomTextContainer(
                    textKey: addNoteKey,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
