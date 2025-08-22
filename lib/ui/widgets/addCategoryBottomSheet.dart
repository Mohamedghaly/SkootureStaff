import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/ui/widgets/customAnimatedRadioButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class AddCategoryBottomSheet extends StatefulWidget {
  final Function(String type, String name)? onAddCategory;
  final Function(int id, String type, String name)? onUpdateCategory;
  final DiaryCategory? categoryToEdit;

  const AddCategoryBottomSheet({
    super.key,
    this.onAddCategory,
    this.onUpdateCategory,
    this.categoryToEdit,
  });

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  String selectedType = "positive";
  final TextEditingController nameController = TextEditingController();

  bool get isEditMode => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      selectedType = widget.categoryToEdit!.type;
      nameController.text = widget.categoryToEdit!.name;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Widget _buildTypeSelection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Positive Radio Button
            SizedBox(
              width: constraints.maxWidth * 0.48,
              child: CustomAnimatedRadioButton(
                textKey: positiveKey,
                isSelected: selectedType == "positive",
                onTap: () {
                  setState(() {
                    selectedType = "positive";
                  });
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
                isSelected: selectedType == "negative",
                onTap: () {
                  setState(() {
                    selectedType = "negative";
                  });
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

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey: isEditMode ? "Edit Category" : "Add New Category",
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Type Selection
            _buildTypeSelection(),

            const SizedBox(height: 20),

            // Category Name Input
            CustomTextFieldContainer(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              hintTextKey: "Enter Title",
              textEditingController: nameController,
            ),

            const SizedBox(height: 20),

            // Add/Update Button
            CustomRoundedButton(
              onTap: () {
                if (nameController.text.trim().isNotEmpty) {
                  if (isEditMode) {
                    widget.onUpdateCategory?.call(
                      widget.categoryToEdit!.id,
                      selectedType,
                      nameController.text.trim(),
                    );
                  } else {
                    widget.onAddCategory?.call(
                      selectedType,
                      nameController.text.trim(),
                    );
                  }
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: isEditMode ? "Update" : "Add",
              showBorder: false,
              widthPercentage: 1.0,
              height: 50,
              radius: 8,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
