import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/classSectionsAndSubjects.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/manageDiary/createDiaryCubit.dart';

import 'package:eschool_saas_staff/cubits/teacherAcademics/manageDiary/diaryCategoriesCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/ui/widgets/customAnimatedRadioButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';

import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  static Widget getRouteInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DiaryCategoriesCubit()),
        BlocProvider(create: (context) => ClassSectionsAndSubjectsCubit()),
        BlocProvider(create: (context) => CreateDiaryCubit()),
      ],
      child: const AddNoteScreen(),
    );
  }

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  String selectedNoteType = "positive"; // positive or negative
  DiaryCategory? selectedCategory;
  TeacherSubject? selectedSubject;
  List<StudentDetails> selectedStudents = [];
  ClassSection? classSection;
  SessionYear? sessionYear;
  DateTime selectedDate = DateTime.now(); // Add selected date state

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get arguments from previous screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      selectedStudents = arguments['selectedStudents'] ?? [];
      classSection = arguments['classSection'];
      sessionYear = arguments['sessionYear'];
    }

    // Initialize categories fetch
    Future.delayed(Duration.zero, () {
      context
          .read<DiaryCategoriesCubit>()
          .fetchDiaryCategories(type: selectedNoteType);

      // Initialize subjects fetch
      if (classSection != null) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
              classSectionId: classSection!.id,
              teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0,
            );
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  void removeStudent(int studentId) {
    setState(() {
      selectedStudents.removeWhere((student) => student.id == studentId);
    });
  }

  void navigateToStudentSelection() async {
    final result = await Get.toNamed(
      Routes.studentDiarySelectionScreen,
      arguments: {
        'selectedStudents': selectedStudents,
        'classSection': classSection,
        'sessionYear': sessionYear,
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      final newlySelectedStudents =
          result['selectedStudents'] as List<StudentDetails>? ?? [];

      setState(() {
        // Replace the entire selectedStudents list with what comes back from selection screen
        // This handles both additions and removals properly
        selectedStudents = newlySelectedStudents.cast<StudentDetails>();
      });
    }
  }

  Future<void> _openDatePicker() async {
    final selectedDateResult = await Utils.openDatePicker(
      context: context,
      inititalDate: selectedDate,
      firstDate: DateTime.now()
          .subtract(const Duration(days: 365)), // Allow past dates
      lastDate:
          DateTime.now().add(const Duration(days: 365)), // Allow future dates
    );

    if (selectedDateResult != null) {
      setState(() {
        selectedDate = selectedDateResult;
      });
    }
  }

  void _showCategorySelectionBottomSheet() {
    final diaryCategoriesState = context.read<DiaryCategoriesCubit>().state;

    debugPrint("Current cubit state: ${diaryCategoriesState.runtimeType}");

    if (diaryCategoriesState is DiaryCategoriesFetchSuccess) {
      final categories = diaryCategoriesState.categories;
      debugPrint("Categories loaded: ${categories.length}");

      // Always show the bottom sheet, regardless of whether categories exist
      Get.bottomSheet(
        BlocProvider.value(
          value: context.read<DiaryCategoriesCubit>(),
          child: _CategorySelectionBottomSheet(
            cubitContext: context, // Pass context instead of static categories
            selectedCategory: selectedCategory,
            onCategorySelected: (DiaryCategory? category) {
              setState(() {
                selectedCategory = category;
              });
            },
            onApply: () {
              Get.back();
            },
            onManage: () async {
              try {
                // First, close the bottom sheet
                Get.back();

                // Add a small delay to ensure bottom sheet is fully closed
                await Future.delayed(const Duration(milliseconds: 300));

                // Navigate to manage category screen and wait for result
                if (context.mounted && mounted) {
                  await Get.toNamed(
                    Routes.manageCategoryScreen,
                    arguments: {
                      'type': selectedNoteType,
                    },
                  );

                  // After returning from manage category screen
                  if (mounted && context.mounted) {
                    // Refresh categories
                    await context
                        .read<DiaryCategoriesCubit>()
                        .fetchDiaryCategories(type: selectedNoteType);

                    // Add a small delay to ensure categories are loaded
                    await Future.delayed(const Duration(milliseconds: 500));

                    // Re-open the category selection bottom sheet if categories are loaded
                    if (mounted && context.mounted) {
                      final updatedState =
                          context.read<DiaryCategoriesCubit>().state;
                      if (updatedState is DiaryCategoriesFetchSuccess) {
                        // Re-show the category selection bottom sheet
                        _showCategorySelectionBottomSheet();
                      }
                    }
                  }
                }
              } catch (e) {
                // Show error to user
                if (mounted) {
                  Utils.showSnackBar(
                    context: context,
                    message: "Failed to open manage categories: $e",
                  );
                }
              }
            },
            noteType: selectedNoteType,
          ),
        ),
      );
    } else if (diaryCategoriesState is DiaryCategoriesFetchInProgress) {
      // Show loading message
      Utils.showSnackBar(
        context: context,
        message: "Loading categories...",
      );
    } else if (diaryCategoriesState is DiaryCategoriesFetchFailure) {
      // Show error message and retry
      Utils.showSnackBar(
        context: context,
        message: "Failed to load categories. Retrying...",
      );
      // Retry loading categories
      context
          .read<DiaryCategoriesCubit>()
          .fetchDiaryCategories(type: selectedNoteType);
    } else {
      // Initial state - fetch categories
      debugPrint("Fetching categories for type: $selectedNoteType");
      context
          .read<DiaryCategoriesCubit>()
          .fetchDiaryCategories(type: selectedNoteType);
      Utils.showSnackBar(
        context: context,
        message: "Loading categories...",
      );
    }
  }

  void _showSubjectSelectionBottomSheet() {
    final subjectsState = context.read<ClassSectionsAndSubjectsCubit>().state;

    if (subjectsState is ClassSectionsAndSubjectsFetchSuccess) {
      final subjects = subjectsState.subjects;

      if (subjects.isNotEmpty) {
        Utils.showBottomSheet(
          child: FilterSelectionBottomsheet<TeacherSubject>(
            selectedValue: selectedSubject,
            showFilterByLabel: false,
            titleKey: subjectKey,
            values: subjects,
            onSelection: (TeacherSubject? value) {
              setState(() {
                selectedSubject = value;
              });
              Get.back();
            },
          ),
          context: context,
        );
      } else {
        // Show message if no subjects found
        Utils.showSnackBar(
          context: context,
          message: "No subjects found for this class",
        );
      }
    } else if (subjectsState is ClassSectionsAndSubjectsFetchInProgress) {
      // Show loading message
      Utils.showSnackBar(
        context: context,
        message: "Loading subjects...",
      );
    } else if (subjectsState is ClassSectionsAndSubjectsFetchFailure) {
      // Show error message and retry
      Utils.showSnackBar(
        context: context,
        message: "Failed to load subjects. Retrying...",
      );
      // Retry loading subjects
      if (classSection != null) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
              classSectionId: classSection!.id,
              teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0,
            );
      }
    } else {
      // Initial state - fetch subjects
      if (classSection != null) {
        context
            .read<ClassSectionsAndSubjectsCubit>()
            .getClassSectionsAndSubjects(
              classSectionId: classSection!.id,
              teacherId: context.read<AuthCubit>().getUserDetails().id ?? 0,
            );
        Utils.showSnackBar(
          context: context,
          message: "Loading subjects...",
        );
      } else {
        Utils.showSnackBar(
          context: context,
          message: "Class section not available",
        );
      }
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      Utils.showSnackBar(
        context: context,
        message: "Please enter a title",
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Utils.showSnackBar(
        context: context,
        message: "Please enter a description",
      );
      return false;
    }

    if (selectedCategory == null) {
      Utils.showSnackBar(
        context: context,
        message: "Please select a category",
      );
      return false;
    }

    if (selectedStudents.isEmpty) {
      Utils.showSnackBar(
        context: context,
        message: "Please select at least one student",
      );
      return false;
    }

    if (classSection == null) {
      Utils.showSnackBar(
        context: context,
        message: "Class section information is missing",
      );
      return false;
    }

    return true;
  }

  Map<int, int> _createStudentClassSectionMap() {
    final Map<int, int> map = {};
    for (final student in selectedStudents) {
      if (student.id != null && student.student?.classSectionId != null) {
        map[student.id!] = student.student!.classSectionId!;
      }
    }
    return map;
  }

  String _getFormattedDate() {
    return "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
  }

  void _clearForm() {
    setState(() {
      // Clear text controllers
      titleController.clear();
      descriptionController.clear();

      // Reset selections
      selectedCategory = null;
      selectedSubject = null;
      selectedStudents.clear();

      // Reset date to current date
      selectedDate = DateTime.now();

      // Reset note type to default
      selectedNoteType = "positive";
    });

    // Refresh categories for the default note type
    context
        .read<DiaryCategoriesCubit>()
        .fetchDiaryCategories(type: selectedNoteType);
  }

  void _createDiary() {
    // Check create permission
    final hasCreatePermission = context
        .read<StaffAllowedPermissionsAndModulesCubit>()
        .isPermissionGiven(permission: createStudentDiaryPermissionKey);

    if (!hasCreatePermission) {
      Utils.showSnackBar(
        context: context,
        message: "You don't have permission to create diary entries",
      );
      return;
    }

    if (!_validateForm()) return;

    final studentClassSectionMap = _createStudentClassSectionMap();
    final formattedDate = _getFormattedDate();

    context.read<CreateDiaryCubit>().createDiary(
          subjectId: selectedSubject?.subjectId,
          diaryCategoryId: selectedCategory!.id,
          date: formattedDate,
          studentClassSectionMap: studentClassSectionMap,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
        );
  }

  Widget _buildNoteTypeSelection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Positive Radio Button
            SizedBox(
              width: constraints.maxWidth * 0.48,
              child: CustomAnimatedRadioButton(
                textKey: positiveKey,
                isSelected: selectedNoteType == "positive",
                onTap: () {
                  setState(() {
                    selectedNoteType = "positive";
                    selectedCategory = null; // Reset category when type changes
                  });
                  // Fetch categories for the new type
                  context
                      .read<DiaryCategoriesCubit>()
                      .fetchDiaryCategories(type: selectedNoteType);
                },
                selectedColor: Colors.green,
                unselectedColor: Theme.of(context).colorScheme.secondary,
                selectedBackgroundColor: Colors.green.withValues(alpha: 0.1),
                unselectedBackgroundColor: Colors.green.withValues(alpha: 0.05),
                fixedBorderColor: Colors.green,
              ),
            ),
            SizedBox(width: constraints.maxWidth * 0.04),
            // Negative Radio Button
            SizedBox(
              width: constraints.maxWidth * 0.48,
              child: CustomAnimatedRadioButton(
                textKey: negativeKey,
                isSelected: selectedNoteType == "negative",
                onTap: () {
                  setState(() {
                    selectedNoteType = "negative";
                    selectedCategory = null; // Reset category when type changes
                  });
                  // Fetch categories for the new type
                  context
                      .read<DiaryCategoriesCubit>()
                      .fetchDiaryCategories(type: selectedNoteType);
                },
                selectedColor: Colors.red,
                unselectedColor: Theme.of(context).colorScheme.secondary,
                selectedBackgroundColor: Colors.red.withValues(alpha: 0.1),
                unselectedBackgroundColor: Colors.red.withValues(alpha: 0.05),
                fixedBorderColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNoteTypeSelection(),
        const SizedBox(height: 25),

        // Title Field
        CustomTextFieldContainer(
          hintTextKey: noteTitleKey,
          textEditingController: titleController,
        ),

        const SizedBox(height: 15),

        // Description Field
        CustomTextFieldContainer(
          hintTextKey: noteDescriptionKey,
          textEditingController: descriptionController,
          maxLines: 4,
          height: 120,
        ),

        const SizedBox(height: 15),

        // Date Selection Field
        CustomSelectionDropdownSelectionButton(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titleKey: Utils.getFormattedDate(selectedDate),
          onTap: _openDatePicker,
        ),

        const SizedBox(height: 15),

        // Select Category Dropdown
        BlocBuilder<DiaryCategoriesCubit, DiaryCategoriesState>(
          builder: (context, state) {
            String titleKey = selectedCategory?.name ?? selectCategoryKey;
            bool isLoading = state is DiaryCategoriesFetchInProgress;

            if (isLoading) {
              titleKey = "Loading categories...";
            } else if (state is DiaryCategoriesFetchFailure) {
              titleKey = "Failed to load categories";
            }

            return CustomSelectionDropdownSelectionButton(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              titleKey: titleKey,
              isDisabled: isLoading,
              onTap: () {
                if (context.mounted) {
                  _showCategorySelectionBottomSheet();
                }
              },
            );
          },
        ),

        const SizedBox(height: 15),

        // Select Subject Dropdown
        BlocBuilder<ClassSectionsAndSubjectsCubit,
            ClassSectionsAndSubjectsState>(
          builder: (context, state) {
            String titleKey =
                selectedSubject?.subject.getSybjectNameWithType() ??
                    selectSubjectOptionalKey;
            bool isLoading = state is ClassSectionsAndSubjectsFetchInProgress;

            if (isLoading) {
              titleKey = "Loading subjects...";
            } else if (state is ClassSectionsAndSubjectsFetchFailure) {
              titleKey = "Failed to load subjects";
            }

            return CustomSelectionDropdownSelectionButton(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              titleKey: titleKey,
              isDisabled: isLoading,
              onTap: () {
                _showSubjectSelectionBottomSheet();
              },
            );
          },
        ),

        const SizedBox(height: 25),

        // Students Section
        _buildStudentsSection(),
      ],
    );
  }

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Students Header with Add Button
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextContainer(
                  textKey: studentsKey,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                CustomTextButton(
                  buttonTextKey: addStudentKey,
                  onTapButton: navigateToStudentSelection,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 15),

        // Students List
        if (selectedStudents.isNotEmpty)
          ...selectedStudents.map((student) => _buildStudentItem(student))
        else
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            child: Center(
              child: CustomTextContainer(
                textKey: "No students selected",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStudentItem(StudentDetails student) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.maxFinite,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          child: Row(
            children: [
              // Profile Image
              SizedBox(
                width: constraints.maxWidth * 0.15,
                child: ProfileImageContainer(
                  imageUrl: student.image ?? "",
                ),
              ),

              const SizedBox(width: 12),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextContainer(
                      textKey: student.fullName ?? "-",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    CustomTextContainer(
                      textKey: "GR No: ${student.student?.admissionNo ?? '-'}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Remove Button
              SizedBox(
                width: constraints.maxWidth * 0.15,
                child: IconButton(
                  onPressed: () => removeStudent(student.id!),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Fields Container
          Expanded(
            child: Container(
              width: double.maxFinite,
              padding:
                  EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    _buildFormFields(),
                    const SizedBox(height: 100), // Space for the Add button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BlocBuilder<CreateDiaryCubit, CreateDiaryState>(
        builder: (context, state) {
          final isLoading = state is CreateDiaryInProgress;

          return LayoutBuilder(
            builder: (context, constraints) {
              return CustomRoundedButton(
                onTap: isLoading ? null : _createDiary,
                backgroundColor: isLoading
                    ? Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.primary,
                buttonTitle: isLoading ? "Creating..." : addKey,
                showBorder: false,
                widthPercentage: 1.0,
                height: 50,
                radius: 8,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<DiaryCategoriesCubit, DiaryCategoriesState>(
              listener: (context, state) {
                if (state is DiaryCategoriesFetchFailure) {
                  Utils.showSnackBar(
                    context: context,
                    message: "Failed to load categories: ${state.errorMessage}",
                  );
                }
              },
            ),
            BlocListener<ClassSectionsAndSubjectsCubit,
                ClassSectionsAndSubjectsState>(
              listener: (context, state) {
                if (state is ClassSectionsAndSubjectsFetchFailure) {
                  Utils.showSnackBar(
                    context: context,
                    message: "Failed to load subjects: ${state.errorMessage}",
                  );
                }
              },
            ),
            BlocListener<CreateDiaryCubit, CreateDiaryState>(
              listener: (context, state) {
                if (state is CreateDiarySuccess) {
                  if (context.mounted) {
                    Utils.showSnackBar(
                      context: context,
                      message: state.message,
                    );
                    // Clear the form after successful creation
                    _clearForm();
                  }
                } else if (state is CreateDiaryFailure) {
                  if (context.mounted) {
                    Utils.showSnackBar(
                      context: context,
                      message: "Failed to create diary: ${state.errorMessage}",
                    );
                  }
                }
              },
            ),
          ],
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Main Content
                  Positioned.fill(
                    top: Utils.appContentTopScrollPadding(context: context),
                    child: _buildContent(),
                  ),

                  // Custom App Bar
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: CustomAppbar(
                      titleKey: addNoteKey,
                      showBackButton: true,
                    ),
                  ),

                  // Add Button (Fixed at bottom)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(child: _buildActionButton()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategorySelectionBottomSheet extends StatefulWidget {
  final BuildContext
      cubitContext; // Changed from List<DiaryCategory> categories
  final DiaryCategory? selectedCategory;
  final Function(DiaryCategory?) onCategorySelected;
  final VoidCallback onApply;
  final VoidCallback onManage;
  final String noteType; // Add note type parameter

  const _CategorySelectionBottomSheet({
    required this.cubitContext, // Changed from required this.categories
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onApply,
    required this.onManage,
    required this.noteType, // Add note type parameter
  });

  @override
  State<_CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<_CategorySelectionBottomSheet> {
  DiaryCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding:
            EdgeInsets.symmetric(vertical: appContentHorizontalPadding * 1.25),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(bottomsheetBorderRadius),
            topRight: Radius.circular(bottomsheetBorderRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 80,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.5),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: appContentHorizontalPadding,
              ),
              child: CustomTextContainer(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textKey: selectCategoryKey,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w800),
              ),
            ),

            // Divider
            Container(
              width: double.maxFinite,
              height: 2,
              color: Theme.of(context).colorScheme.tertiary,
            ),

            // Category List
            Flexible(
              child: BlocBuilder<DiaryCategoriesCubit, DiaryCategoriesState>(
                builder: (context, state) {
                  if (state is DiaryCategoriesFetchInProgress) {
                    // Show loading message
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: appContentHorizontalPadding,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomCircularProgressIndicator(),
                            const SizedBox(height: 16),
                            CustomTextContainer(
                              textKey: "Loading categories...",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is DiaryCategoriesFetchFailure) {
                    // Show error message and retry
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: appContentHorizontalPadding,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 16),
                            CustomTextContainer(
                              textKey: "Failed to load categories. Retrying...",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            CustomRoundedButton(
                              onTap: () {
                                context
                                    .read<DiaryCategoriesCubit>()
                                    .fetchDiaryCategories(
                                        type: widget.noteType);
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              buttonTitle: "Retry",
                              showBorder: false,
                              widthPercentage: 0.8,
                              height: 50,
                              radius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is DiaryCategoriesFetchSuccess) {
                    final categories = state.categories;
                    if (categories.isEmpty) {
                      // Show message when no categories exist
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: appContentHorizontalPadding,
                            vertical: 40,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              CustomTextContainer(
                                textKey: Utils.getTranslatedLabel(
                                  noCategoryFoundKey,
                                ),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              CustomRoundedButton(
                                onTap: widget.onManage,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                buttonTitle: Utils.getTranslatedLabel(
                                  createNewCategoryKey,
                                ),
                                showBorder: false,
                                widthPercentage: 0.8,
                                height: 50,
                                radius: 8,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Show existing categories
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            ...categories.map(
                                (category) => _buildCategoryItem(category)),
                          ],
                        ),
                      );
                    }
                  } else {
                    // Initial state - show message
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: appContentHorizontalPadding,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            CustomTextContainer(
                              textKey: "No categories loaded",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            // Bottom Buttons
            Container(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              child: Row(
                children: [
                  // Manage Button
                  Expanded(
                    child: CustomRoundedButton(
                      onTap: widget.onManage,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      buttonTitle: "Manage",
                      showBorder: true,
                      widthPercentage: 1.0,
                      height: 50,
                      radius: 8,
                      borderColor: Theme.of(context).colorScheme.primary,
                      titleColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Apply Button
                  Expanded(
                    child: CustomRoundedButton(
                      onTap: () {
                        widget.onCategorySelected(_selectedCategory);
                        widget.onApply();
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: "Apply",
                      showBorder: false,
                      widthPercentage: 1.0,
                      height: 50,
                      radius: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(DiaryCategory category) {
    final isSelected = _selectedCategory?.id == category.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding:
              EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          alignment: Alignment.topCenter,
          child: Row(
            children: [
              Expanded(
                child: CustomTextContainer(
                  textKey: category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                width: 20,
                height: 20,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.5,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: isSelected
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
