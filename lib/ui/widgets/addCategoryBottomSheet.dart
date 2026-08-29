import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/ui/widgets/customAnimatedRadioButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class AddCategoryBottomSheet extends StatefulWidget {
  final String? type;
  final Function(String type, String name)? onAddCategory;
  final Function(int id, String type, String name)? onUpdateCategory;
  final DiaryCategory? categoryToEdit;

  const AddCategoryBottomSheet({
    super.key,
    this.onAddCategory,
    this.onUpdateCategory,
    this.categoryToEdit,
    this.type,
  });

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  late String selectedType;
  final TextEditingController nameController = TextEditingController();
  bool showValidationError = false;

  bool get isEditMode => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    selectedType = widget.type ?? "positive";
    if (isEditMode) {
      selectedType = widget.categoryToEdit!.type;
      nameController.text = widget.categoryToEdit!.name;
    }

    // Listen to text changes to clear validation error
    nameController.addListener(() {
      if (showValidationError && nameController.text.trim().isNotEmpty) {
        setState(() {
          showValidationError = false;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Validate input
    if (nameController.text.trim().isEmpty) {
      setState(() {
        showValidationError = true;
      });

      // Show error message
      Utils.showSnackBar(
        context: context,
        message: pleaseEnterTitleKey,
        backgroundColor: Colors.red,
      );
      return;
    }

    // If validation passes, proceed with the action
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
      titleLabelKey: isEditMode ? editCategoryKey : addNewCategoryKey,
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
              hintTextKey: enterTitleKey,
              textEditingController: nameController,
              borderColor: showValidationError ? Colors.red : null,
            ),

            // Validation Error Message
            if (showValidationError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  Utils.getTranslatedLabel(titleIsRequiredKey),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Add/Update Button
            CustomRoundedButton(
              onTap: _handleSubmit,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: isEditMode ? updateKey : addKey,
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
