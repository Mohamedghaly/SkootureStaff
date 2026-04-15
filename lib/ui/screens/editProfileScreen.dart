import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/editProfileCubit.dart';
import 'package:eschool_saas_staff/data/models/customField.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customFieldWidgets.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => EditProfileCubit(),
      child: const EditProfileScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  TextEditingController currentAddress = TextEditingController();
  TextEditingController permanentAddress = TextEditingController();
  late DateTime _dateOfBirth = DateTime.now();
  String selectedGender = '';
  String profileImage = '';
  String? uploadedPicture;

  // Custom fields management
  Map<String, TextEditingController> customFieldControllers = {};
  Map<String, String?> customFieldUploadedFiles = {};
  List<CustomField> customFields = [];

  @override
  void initState() {
    firstName = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().firstName ?? "");
    lastName = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().lastName ?? "");
    mobileNumber = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().mobile ?? "");
    email = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().email ?? "");
    dateOfBirth = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().dob ?? "");
    currentAddress = TextEditingController(
        text: context.read<AuthCubit>().getUserDetails().currentAddress ?? "");
    permanentAddress = TextEditingController(
        text:
            context.read<AuthCubit>().getUserDetails().permanentAddress ?? "");
    selectedGender = context.read<AuthCubit>().getUserDetails().gender ?? "";
    profileImage = context.read<AuthCubit>().getUserDetails().image ?? "";

    // Initialize custom fields
    customFields =
        context.read<AuthCubit>().getUserDetails().customFields ?? [];
    for (var field in customFields) {
      final fieldName = field.name ?? '';
      customFieldControllers[fieldName] =
          TextEditingController(text: field.value ?? '');
    }

    super.initState();
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    mobileNumber.dispose();
    email.dispose();
    dateOfBirth.dispose();
    currentAddress.dispose();
    permanentAddress.dispose();

    // Dispose custom field controllers
    for (var controller in customFieldControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _addFiles() async {
    final result = await Utils.openFilePicker(
        context: context, allowMultiple: false, type: FileType.image);
    if (result != null) {
      uploadedPicture = result.files.first.path;
      setState(() {});
    }
  }

  Future<void> _addCustomFieldFile(String fieldName) async {
    final result = await Utils.openFilePicker(
        context: context, allowMultiple: false, type: FileType.image);
    if (result != null) {
      customFieldUploadedFiles[fieldName] = result.files.first.path;
      setState(() {});
    }
  }

  bool _validateCustomFields() {
    for (var field in customFields) {
      if (field.isRequired == true) {
        final fieldName = field.name ?? '';
        final controller = customFieldControllers[fieldName];
        final value = controller?.text.trim() ?? '';

        if (value.isEmpty) {
          // Check if it's a file field with uploaded file
          if (field.type == 'file' &&
              customFieldUploadedFiles[fieldName]?.isNotEmpty == true) {
            continue;
          }

          Utils.showSnackBar(
            message: 'Please fill required field: $fieldName',
            context: context,
          );
          return false;
        }
      }
    }
    return true;
  }

  /// Prepares custom fields data in the format required by the API
  /// Format: custom_fields[i][id], custom_fields[i][form_field_id],
  ///         custom_fields[i][input_type], custom_fields[i][data]
  List<Map<String, dynamic>> _prepareCustomFieldsData() {
    return customFields.map((field) {
      final fieldName = field.name ?? '';
      final controller = customFieldControllers[fieldName];
      final uploadedFile = customFieldUploadedFiles[fieldName];

      // Get the value based on field type
      String fieldValue = controller?.text.trim() ?? '';

      // Handle empty values - use "null" string for radio buttons without selection
      if (fieldValue.isEmpty && field.type == 'radio') {
        fieldValue = 'null';
      }

      return {
        'id': field.id, // Custom field value record ID
        'form_field_id': field.formFieldId, // Form field definition ID
        'input_type': field.type, // Field type (textarea, radio, file, etc.)
        'data': fieldValue, // The actual value
        'uploaded_file': uploadedFile, // File path for file type fields
      };
    }).toList();
  }

  Widget _buildCustomFields() {
    if (customFields.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort custom fields by rank
    final sortedFields = List<CustomField>.from(customFields)
      ..sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Section header for custom fields
        Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 15),
        ...sortedFields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          final fieldName = field.name ?? '';
          final controller = customFieldControllers[fieldName];

          if (controller == null) return const SizedBox.shrink();

          return Container(
            key: ValueKey(
                'custom_field_${field.id ?? index}_${field.formFieldId}'),
            child: CustomFieldWidgets.buildCustomFieldWidget(
              context: context,
              field: field,
              controller: controller,
              onChanged: (value) {
                setState(() {});
              },
              uploadedFilePath: customFieldUploadedFiles[fieldName],
              onFileUpload: field.type == 'file'
                  ? () => _addCustomFieldFile(fieldName)
                  : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLabelWithTextEditingController(
      {required String labelTitle,
      required String textFieldHintTextKey,
      required TextEditingController textEditingController,
      bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextContainer(
              textKey: labelTitle,
              style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.76)),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        CustomTextFieldContainer(
            textEditingController: textEditingController,
            hintTextKey: textFieldHintTextKey),
      ],
    );
  }

  Widget _buildDateOfBirthContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextContainer(
              textKey: dateOfBirthKey,
              style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.76)),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 13.0,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
                context: context,
                currentDate: _dateOfBirth,
                firstDate: DateTime(1900),
                lastDate: DateTime.now());
            if (selectedDate != null) {
              _dateOfBirth = selectedDate;
              dateOfBirth.text = DateFormat("yyyy-MM-dd").format(_dateOfBirth);
              setState(() {});
            }
          },
          child: Container(
            height: 50,
            padding:
                EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(5),
                border:
                    Border.all(color: Theme.of(context).colorScheme.tertiary)),
            alignment: AlignmentDirectional.centerStart,
            child: CustomTextContainer(textKey: dateOfBirth.text),
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  Widget _buildRadioselection(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary)),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: appContentHorizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title),
          Radio<String>(
            value: title,
            // Remove groupValue and onChanged - they're now handled by RadioGroup
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return RadioGroup<String>(
      groupValue: selectedGender,
      onChanged: (String? value) {
        setState(() {
          selectedGender = value ?? '';
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(flex: 1, child: _buildRadioselection("male")),
          const SizedBox(width: 20),
          Expanded(flex: 1, child: _buildRadioselection("female")),
        ],
      ),
    );
  }

  Widget _buildUpdateProfileButton(EditProfileState state) {
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
            buttonTitle: updateProfileKey,
            showBorder: false,
            child: state is EditProfileProgress
                ? const CustomCircularProgressIndicator()
                : null,
            onTap: () {
              if (state is EditProfileProgress) {
                return;
              }
              if (firstName.text.trim().isEmpty ||
                  lastName.text.trim().isEmpty ||
                  mobileNumber.text.trim().isEmpty ||
                  email.text.trim().isEmpty ||
                  dateOfBirth.text.trim().isEmpty) {
                Utils.showSnackBar(
                    message: pleaseAddNeededDetailsKey, context: context);
                return;
              }

              // Validate email format
              if (!Utils.isValidEmail(email.text.trim())) {
                Utils.showSnackBar(
                    message: pleaseEnterValidEmailKey, context: context);
                return;
              }

              // Validate current and permanent address for teachers
              if (context.read<AuthCubit>().isTeacher()) {
                if (currentAddress.text.trim().isEmpty ||
                    permanentAddress.text.trim().isEmpty) {
                  Utils.showSnackBar(
                      message: pleaseAddNeededDetailsKey, context: context);
                  return;
                }
              }

              // Validate custom fields
              if (!_validateCustomFields()) {
                return;
              }

              context.read<EditProfileCubit>().editProfile(
                    firstName: firstName.text.trim(),
                    lastName: lastName.text.trim(),
                    mobileNumber: mobileNumber.text.trim(),
                    email: email.text.trim(),
                    dateOfBirth: dateOfBirth.text.trim(),
                    currentAddress: currentAddress.text.trim(),
                    permanentAddress: permanentAddress.text.trim(),
                    gender: selectedGender,
                    image: uploadedPicture ?? "",
                    customFieldsData: _prepareCustomFieldsData(),
                  );
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
      if (state is EditProfileSuccess) {
        context.read<AuthCubit>().updateuserDetail(state.userDetails);
        // Navigate back and pass success message
        Get.back(result: state.successMessage);
      } else if (state is EditProfileFailure) {
        Utils.showSnackBar(message: state.errorMessage, context: context);
      }
    }, builder: (context, state) {
      return PopScope(
        canPop: state is! EditProfileProgress,
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: 100,
                      top: Utils.appContentTopScrollPadding(context: context) +
                          10),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15.0,
                        ),
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: profileImage.isEmpty
                                        ? null
                                        : DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                                profileImage)),
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                child: uploadedPicture != null
                                    ? Image.file(
                                        File(uploadedPicture!),
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : profileImage.isEmpty
                                        ? const Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 25,
                                            ),
                                          )
                                        : null,
                              ),
                              Align(
                                alignment: AlignmentDirectional.bottomEnd,
                                child: Container(
                                  margin: const EdgeInsetsDirectional.only(
                                      bottom: 7.50, end: 7.50),
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius:
                                          BorderRadius.circular(2.50)),
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    onTap: () => _addFiles(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        _buildLabelWithTextEditingController(
                            labelTitle: firstNameKey,
                            textFieldHintTextKey: firstNameKey,
                            textEditingController: firstName,
                            isRequired: true),
                        _buildLabelWithTextEditingController(
                            labelTitle: lastNameKey,
                            textFieldHintTextKey: lastNameKey,
                            textEditingController: lastName,
                            isRequired: true),
                        _buildLabelWithTextEditingController(
                            labelTitle: mobileNumberKey,
                            textFieldHintTextKey: mobileNumberKey,
                            textEditingController: mobileNumber,
                            isRequired: true),
                        _buildLabelWithTextEditingController(
                            labelTitle: emailKey,
                            textFieldHintTextKey: emailKey,
                            textEditingController: email,
                            isRequired: true),
                        _buildDateOfBirthContainer(),
                        context.read<AuthCubit>().isTeacher()
                            ? _buildLabelWithTextEditingController(
                                labelTitle: currentAddressKey,
                                textFieldHintTextKey: currentAddressKey,
                                textEditingController: currentAddress,
                                isRequired: true)
                            : const SizedBox(),
                        context.read<AuthCubit>().isTeacher()
                            ? _buildLabelWithTextEditingController(
                                labelTitle: permanentAddressKey,
                                textFieldHintTextKey: permanentAddressKey,
                                textEditingController: permanentAddress,
                                isRequired: true)
                            : const SizedBox(),
                        _buildGenderSelector(),
                        // Display custom fields
                        _buildCustomFields(),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(child: _buildUpdateProfileButton(state)),
              Align(
                alignment: Alignment.topCenter,
                child: CustomAppbar(
                  titleKey: editProfileKey,
                  onBackButtonTap: () {
                    if (state is EditProfileProgress) {
                      return;
                    }
                    Get.back();
                  },
                ),
              )
            ],
          ),
        ),
      );
    }));
  }
}
