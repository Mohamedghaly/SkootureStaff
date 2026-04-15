import 'package:eschool_saas_staff/cubits/teacherAcademics/manageDiary/diaryCategoriesCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/manageDiary/createDiaryCategoryCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/manageDiary/updateDiaryCategoryCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/manageDiary/deleteDiaryCategoryCubit.dart';
import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/ui/widgets/addCategoryBottomSheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ManageCategoryScreen extends StatefulWidget {
  final String? type;
  const ManageCategoryScreen({super.key, this.type});

  static Widget getRouteInstance({String? type}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DiaryCategoriesCubit()),
        BlocProvider(create: (context) => CreateDiaryCategoryCubit()),
        BlocProvider(create: (context) => UpdateDiaryCategoryCubit()),
        BlocProvider(create: (context) => DeleteDiaryCategoryCubit()),
      ],
      child: ManageCategoryScreen(type: type),
    );
  }

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch categories based on the provided type
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<DiaryCategoriesCubit>()
            .fetchDiaryCategories(type: widget.type ?? "positive");
      }
    });
  }

  void _onAddCategory() {
    Get.bottomSheet(
      AddCategoryBottomSheet(
        type: widget.type,
        onAddCategory: (String type, String name) {
          // Call the create category API - No setState needed
          context.read<CreateDiaryCategoryCubit>().createDiaryCategory(
                name: name,
                type: type,
              );
          Get.back(); // Close the bottom sheet
        },
      ),
      isScrollControlled: true,
    );
  }

  void _onEditCategory(DiaryCategory category) {
    Get.bottomSheet(
      AddCategoryBottomSheet(
        categoryToEdit: category,
        onUpdateCategory: (int id, String type, String name) {
          // Call the update category API - No setState needed
          context.read<UpdateDiaryCategoryCubit>().updateDiaryCategory(
                diaryCategoryId: id,
                name: name,
                type: type,
              );
          Get.back(); // Close the bottom sheet
        },
      ),
      isScrollControlled: true,
    );
  }

  void _onDeleteCategory(DiaryCategory category) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Call the delete category API - No setState needed
              context.read<DeleteDiaryCategoryCubit>().deleteDiaryCategory(
                    diaryCategoryId: category.id,
                  );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(DiaryCategory category) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Category Name
          Expanded(
            child: CustomTextContainer(
              textKey: category.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // Edit Button
          IconButton(
            onPressed: () => _onEditCategory(category),
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: () => _onDeleteCategory(category),
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<DiaryCategory> categories) {
    if (categories.isEmpty) {
      return noDataContainer(titleKey: "No categories found");
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.only(bottom: 8),
          color: Theme.of(context).colorScheme.surface,
          child: _buildCategoryItem(categories[index]),
        );
      },
    );
  }

  Widget _buildContent() {
    return BlocBuilder<DiaryCategoriesCubit, DiaryCategoriesState>(
      builder: (context, state) {
        if (state is DiaryCategoriesFetchInProgress) {
          return const Center(
            child: CustomCircularProgressIndicator(),
          );
        } else if (state is DiaryCategoriesFetchSuccess) {
          return _buildCategoryList(state.categories);
        } else if (state is DiaryCategoriesFetchFailure) {
          return ErrorContainer(
            errorMessage: state.errorMessage,
            onTapRetry: () {
              context
                  .read<DiaryCategoriesCubit>()
                  .fetchDiaryCategories(type: widget.type ?? "positive");
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Return with a result to indicate categories were managed
          Get.back(result: true);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: MultiBlocListener(
          listeners: [
            BlocListener<CreateDiaryCategoryCubit, CreateDiaryCategoryState>(
              listener: (context, state) {
                if (state is CreateDiaryCategorySuccess) {
                  // Refresh the categories list
                  context
                      .read<DiaryCategoriesCubit>()
                      .fetchDiaryCategories(type: widget.type ?? "positive");
                  // Show success message
                  Utils.showSnackBar(
                    context: context,
                    message: "Category created successfully",
                  );
                } else if (state is CreateDiaryCategoryFailure) {
                  // Show error message
                  Utils.showSnackBar(
                    context: context,
                    message: "Failed to create category: ${state.errorMessage}",
                  );
                }
              },
            ),
            BlocListener<UpdateDiaryCategoryCubit, UpdateDiaryCategoryState>(
              listener: (context, state) {
                if (state is UpdateDiaryCategorySuccess) {
                  // Refresh the categories list
                  context
                      .read<DiaryCategoriesCubit>()
                      .fetchDiaryCategories(type: widget.type ?? "positive");
                  // Show success message
                  Utils.showSnackBar(
                    context: context,
                    message: "Category updated successfully",
                  );
                } else if (state is UpdateDiaryCategoryFailure) {
                  // Show error message
                  Utils.showSnackBar(
                    context: context,
                    message: "Failed to update category: ${state.errorMessage}",
                  );
                }
              },
            ),
            BlocListener<DeleteDiaryCategoryCubit, DeleteDiaryCategoryState>(
              listener: (context, state) {
                if (state is DeleteDiaryCategorySuccess) {
                  // Refresh the categories list
                  context
                      .read<DiaryCategoriesCubit>()
                      .fetchDiaryCategories(type: widget.type ?? "positive");
                  // Show success message
                  Utils.showSnackBar(
                    context: context,
                    message: "Category deleted successfully",
                  );
                } else if (state is DeleteDiaryCategoryFailure) {
                  // Show error message
                  Utils.showSnackBar(
                    context: context,
                    message: "Failed to delete category: ${state.errorMessage}",
                  );
                }
              },
            ),
          ],
          child: Column(
            children: [
              // Custom App Bar
              CustomAppbar(
                titleKey: "Manage Category",
                showBackButton: true,
                onBackButtonTap: () {
                  // Return with a result to indicate categories were managed
                  Get.back(result: true);
                },
                trailingWidget: IconButton(
                  onPressed: _onAddCategory,
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content
              Expanded(
                child: SizedBox(
                  width: double.maxFinite,
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
