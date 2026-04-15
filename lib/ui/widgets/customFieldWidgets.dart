import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/data/models/customField.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget builder for custom fields based on their type
class CustomFieldWidgets {
  /// Build a custom field widget based on field type
  static Widget buildCustomFieldWidget({
    required BuildContext context,
    required CustomField field,
    required TextEditingController controller,
    required Function(String?) onChanged,
    String? uploadedFilePath,
    VoidCallback? onFileUpload,
  }) {
    // Display field name with required indicator
    final fieldLabel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                field.name ?? 'Field',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.76),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (field.isRequired == true)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );

    switch (field.type?.toLowerCase()) {
      case 'text':
        return _buildTextField(context, fieldLabel, controller);

      case 'number':
        return _buildNumberField(context, fieldLabel, controller);

      case 'textarea':
        return _buildTextAreaField(context, fieldLabel, controller);

      case 'dropdown':
        return _buildDropdownField(
            context, fieldLabel, field, controller, onChanged);

      case 'radio':
        return _buildRadioField(
            context, fieldLabel, field, controller, onChanged);

      case 'checkbox':
        return _buildCheckboxField(
            context, fieldLabel, field, controller, onChanged);

      case 'file':
        return _buildFileUploadField(
          context,
          fieldLabel,
          field,
          controller,
          uploadedFilePath,
          onFileUpload,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Build text field
  static Widget _buildTextField(
    BuildContext context,
    Widget label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        CustomTextFieldContainer(
          textEditingController: controller,
          hintTextKey: 'Enter text',
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  /// Build number field
  static Widget _buildNumberField(
    BuildContext context,
    Widget label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        CustomTextFieldContainer(
          textEditingController: controller,
          hintTextKey: 'Enter number',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  /// Build textarea field
  static Widget _buildTextAreaField(
    BuildContext context,
    Widget label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          ),
          padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter text',
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  /// Build dropdown field
  static Widget _buildDropdownField(
    BuildContext context,
    Widget label,
    CustomField field,
    TextEditingController controller,
    Function(String?) onChanged,
  ) {
    final options = field.getOptionsAsList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.text.isNotEmpty && options.contains(controller.text)
                  ? controller.text
                  : null,
              hint: const Text('Select option'),
              isExpanded: true,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.text = newValue;
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  /// Build radio button field
  static Widget _buildRadioField(
    BuildContext context,
    Widget label,
    CustomField field,
    TextEditingController controller,
    Function(String?) onChanged,
  ) {
    final options = field.getOptionsAsList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        RadioGroup<String>(
          groupValue: controller.text.isNotEmpty ? controller.text : null,
          onChanged: (String? value) {
            if (value != null) {
              controller.text = value;
              onChanged(value);
            }
          },
          child: Column(
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  /// Build checkbox field
  static Widget _buildCheckboxField(
    BuildContext context,
    Widget label,
    CustomField field,
    TextEditingController controller,
    Function(String?) onChanged,
  ) {
    final options = field.getOptionsAsList();
    // For checkbox, we store comma-separated values
    final selectedValues = controller.text.isNotEmpty
        ? controller.text.split(',').map((e) => e.trim()).toList()
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        ...options.map((option) {
          final isChecked = selectedValues.contains(option);
          return CheckboxListTile(
            title: Text(option),
            value: isChecked,
            onChanged: (bool? value) {
              if (value == true) {
                if (!selectedValues.contains(option)) {
                  selectedValues.add(option);
                }
              } else {
                selectedValues.remove(option);
              }
              controller.text = selectedValues.join(',');
              onChanged(controller.text);
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
        const SizedBox(height: 15),
      ],
    );
  }

  /// Build file upload field with support for existing files and new uploads
  static Widget _buildFileUploadField(
    BuildContext context,
    Widget label,
    CustomField field,
    TextEditingController controller,
    String? uploadedFilePath,
    VoidCallback? onFileUpload, {
    Key? key,
  }) {
    // Determine if there's an existing file (from server) or newly uploaded file
    // Check if controller text is a URL (http:// or https://)
    final hasExistingFile = controller.text.isNotEmpty &&
        (controller.text.startsWith('http://') ||
            controller.text.startsWith('https://') ||
            controller.text.contains('/storage/'));
    final hasUploadedFile = uploadedFilePath != null && uploadedFilePath.isNotEmpty;

    // Build the file URL - handle both full URLs and relative paths
    String? existingFileUrl;
    if (hasExistingFile) {
      if (controller.text.startsWith('http://') ||
          controller.text.startsWith('https://')) {
        existingFileUrl = controller.text;
      } else if (controller.text.contains('/storage/')) {
        // If it's a path starting with /storage/, use it as is
        existingFileUrl = controller.text.startsWith('/')
            ? '$baseUrl${controller.text}'
            : '$baseUrl/${controller.text}';
      } else {
        // Fallback: assume it's a relative path
        existingFileUrl = '$baseUrl/storage/${controller.text}';
      }
    }

    return Column(
      key: key ?? ValueKey('file_field_${field.id ?? field.name}_${field.formFieldId}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        GestureDetector(
          onTap: () {
            // If file exists, show full view. Otherwise, upload
            if (hasUploadedFile || hasExistingFile) {
              // Show full image view
              if (hasUploadedFile) {
                // For local files, show dialog with the local file
                _showLocalImagePreview(context, uploadedFilePath);
              } else if (existingFileUrl != null) {
                // For network images, use Utils method
                Utils.showImagePreview(
                  context: context,
                  imageUrl: existingFileUrl,
                  heroTag: 'custom_field_${field.name}',
                );
              }
            } else {
              // No file exists, trigger upload
              onFileUpload?.call();
            }
          },
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Stack(
              children: [
                // Show uploaded file (new file takes priority)
                if (hasUploadedFile)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(uploadedFilePath),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      key: ValueKey(uploadedFilePath), // Force rebuild on file change
                    ),
                  )
                // Show existing file from server
                else if (hasExistingFile && existingFileUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: existingFileUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      key: ValueKey(existingFileUrl), // Force rebuild on URL change
                      placeholder: (context, url) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                // Show upload prompt when no file
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to upload image',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG, PNG (Max 5MB)',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Overlay edit icon when file exists
                if (hasUploadedFile || hasExistingFile)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        // Always trigger upload when edit icon is tapped
                        onFileUpload?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Status indicator
        if (hasUploadedFile || hasExistingFile)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Icon(
                  hasUploadedFile ? Icons.check_circle : Icons.cloud_done,
                  color: hasUploadedFile ? Colors.green : Colors.blue,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasUploadedFile
                        ? 'New file selected (will be uploaded on save)'
                        : 'File already uploaded',
                    style: TextStyle(
                      color: hasUploadedFile ? Colors.green : Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onFileUpload != null)
                  TextButton.icon(
                    onPressed: onFileUpload,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Change'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 15),
      ],
    );
  }

  /// Show full screen preview for local image files
  static Future<void> _showLocalImagePreview(
      BuildContext context, String filePath) async {
    await showGeneralDialog(
      context: context,
      barrierLabel: 'local_image_preview',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(dialogContext).maybePop(),
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                child: Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image.file(
                          File(filePath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Material(
                        color: Colors.black45,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(dialogContext).maybePop(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
