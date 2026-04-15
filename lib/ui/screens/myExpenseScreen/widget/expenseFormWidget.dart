import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eschool_saas_staff/data/models/expense.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class ExpenseFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController reasonController;
  final List<VehicleDetails> vehicles;
  final List<ExpenseCategory> categories;
  final Vehicle? selectedVehicle;
  final ExpenseCategory? selectedCategory;
  final File? selectedFile;
  final Function(Vehicle?) onVehicleChanged;
  final Function(ExpenseCategory?) onCategoryChanged;
  final Function(File?) onFileChanged;

  const ExpenseFormWidget({
    super.key,
    required this.formKey,
    required this.amountController,
    required this.reasonController,
    required this.vehicles,
    required this.categories,
    required this.selectedVehicle,
    required this.selectedCategory,
    required this.selectedFile,
    required this.onVehicleChanged,
    required this.onCategoryChanged,
    required this.onFileChanged,
  });

  @override
  State<ExpenseFormWidget> createState() => _ExpenseFormWidgetState();
}

class _ExpenseFormWidgetState extends State<ExpenseFormWidget> {
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        widget.onFileChanged(File(result.files.single.path!));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomTextContainer(
            textKey: '${Utils.getTranslatedLabel(errorPickingFileKey)}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile() {
    widget.onFileChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Your Vehicle
          CustomTextContainer(
            textKey: selectYourVehicleKey,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Vehicle>(
                value: widget.selectedVehicle,
                hint: CustomTextContainer(
                  textKey: busNoPlaceholderKey,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: widget.vehicles.map((vehicleDetail) {
                  return DropdownMenuItem<Vehicle>(
                    value: vehicleDetail.vehicle,
                    child: Text(
                      vehicleDetail.vehicle.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: widget.onVehicleChanged,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Category
          CustomTextContainer(
            textKey: categoryKey,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ExpenseCategory>(
                value: widget.selectedCategory,
                hint: CustomTextContainer(
                  textKey: fuelPlaceholderKey,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<ExpenseCategory>(
                    value: category,
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: widget.onCategoryChanged,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Expense Amount
          CustomTextContainer(
            textKey: expenseAmountKey,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: Utils.getTranslatedLabel(amountPlaceholderKey),
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return Utils.getTranslatedLabel(pleaseEnterExpenseAmountKey);
              }
              if (double.tryParse(value) == null) {
                return Utils.getTranslatedLabel(pleaseEnterValidAmountKey);
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Expense Reason
          CustomTextContainer(
            textKey: expenseReasonKey,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.reasonController,
            decoration: InputDecoration(
              hintText: Utils.getTranslatedLabel(fillingFuelPlaceholderKey),
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return Utils.getTranslatedLabel(pleaseEnterExpenseReasonKey);
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Upload File Section
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.upload_file,
                      color: Colors.green.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextContainer(
                    textKey: uploadFileKey,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // File upload note
          CustomTextContainer(
            textKey: fileUploadNoteKey,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
            ),
          ),

          const SizedBox(height: 16),

          // Selected file display
          if (widget.selectedFile != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.selectedFile!.path.split('/').last,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _removeFile,
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
