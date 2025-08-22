import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/announcement/sendNotificationCubit.dart';
import 'package:eschool_saas_staff/cubits/rolesCubit.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/screens/manageNotification/manageNotificationScreen.dart';
import 'package:eschool_saas_staff/ui/screens/searchUsersScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customDropdownSelectionButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/multiSelectionValueBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RolesCubit(),
        ),
        BlocProvider(
          create: (context) => SendNotificationCubit(),
        ),
      ],
      child: const AddNotificationScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  String _sendToUserValue = "";

  final TextEditingController _titleTextEditingController =
      TextEditingController();

  final TextEditingController _messageTextEditingController =
      TextEditingController();

  List<String> _selectedRoles = [];

  List<UserDetails> _selectedUsers = [];

  PlatformFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<RolesCubit>().getRoles();
      }
    });
  }

  @override
  void dispose() {
    _titleTextEditingController.dispose();
    _messageTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await Utils.openFilePicker(
        context: context, allowMultiple: false, type: FileType.image);
    if (result != null) {
      _pickedFile = result.files.first;
      setState(() {});
    }
  }

  void onTapSubmitButton() {
    if (_titleTextEditingController.text.trim().isEmpty) {
      Utils.showSnackBar(message: pleaseEnterTitleKey, context: context);
      return;
    }
    if (_messageTextEditingController.text.trim().isEmpty) {
      Utils.showSnackBar(message: pleaseEnterMessageKey, context: context);
      return;
    }
    if (_sendToUserValue.isEmpty) {
      Utils.showSnackBar(message: pleaseSelectSendToKey, context: context);
      return;
    }

    if (_sendToUserValue == specificRolesKey && _selectedRoles.isEmpty) {
      Utils.showSnackBar(message: pleaseSelectSendToKey, context: context);
      return;
    }

    if (_sendToUserValue == specificUsersKey && _selectedUsers.isEmpty) {
      Utils.showSnackBar(message: pleaseSelectUserKey, context: context);
      return;
    }

    context.read<SendNotificationCubit>().sendNotification(
        title: _titleTextEditingController.text.trim(),
        userIds: _selectedUsers.map((e) => e.id ?? 0).toList(),
        filePath: _pickedFile?.path,
        message: _messageTextEditingController.text.trim(),
        roles: _selectedRoles,
        sendToType: _sendToUserValue);
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<RolesCubit, RolesState>(
      builder: (context, state) {
        if (state is RolesFetchSuccess) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 1, spreadRadius: 1)
                ], color: Theme.of(context).colorScheme.surface),
                width: MediaQuery.of(context).size.width,
                height: 70,
                child:
                    BlocConsumer<SendNotificationCubit, SendNotificationState>(
                  listener: (context, sendNotificationState) {
                    if (sendNotificationState is SendNotificationFailure) {
                      Utils.showSnackBar(
                          message: sendNotificationState.errorMessage,
                          context: context);
                    } else if (sendNotificationState
                        is SendNotificationSuccess) {
                      ManageNotificationScreen.screenKey.currentState
                          ?.getNotifications();
                      Utils.showSnackBar(
                          message: notificationSentSuccessfullyKey,
                          context: context);
                      _titleTextEditingController.clear();
                      _messageTextEditingController.clear();
                      _sendToUserValue = "";
                      _selectedRoles.clear();
                      _selectedUsers.clear();
                      _pickedFile = null;
                      setState(() {});
                    }
                  },
                  builder: (context, sendNotificationState) {
                    return PopScope(
                      canPop:
                          sendNotificationState is! SendNotificationInProgress,
                      child: CustomRoundedButton(
                        height: 40,
                        widthPercentage: 1.0,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        buttonTitle: submitKey,
                        showBorder: false,
                        child:
                            sendNotificationState is SendNotificationInProgress
                                ? const CustomCircularProgressIndicator()
                                : null,
                        onTap: () {
                          if (sendNotificationState
                              is SendNotificationInProgress) {
                            return;
                          }
                          onTapSubmitButton();
                        },
                      ),
                    );
                  },
                ),
              ));
        }
        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocBuilder<RolesCubit, RolesState>(
          builder: (context, state) {
            if (state is RolesFetchSuccess) {
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
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        hintTextKey: titleKey,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomTextFieldContainer(
                        textEditingController: _messageTextEditingController,
                        maxLines: 5,
                        hintTextKey: messageKey,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomSelectionDropdownSelectionButton(
                          onTap: () {
                            Utils.showBottomSheet(
                                child: FilterSelectionBottomsheet<String>(
                                    onSelection: (value) {
                                      if (_sendToUserValue != value) {
                                        _sendToUserValue = value!;
                                        _selectedRoles.clear();
                                        setState(() {});
                                        Get.back();
                                      }
                                    },
                                    selectedValue: _sendToUserValue,
                                    titleKey: sendToKey,
                                    values: const [
                                      allUsersKey,
                                      overDueFeesKey,
                                      specificRolesKey,
                                      specificUsersKey
                                    ]),
                                context: context);
                          },
                          titleKey: _sendToUserValue.isEmpty
                              ? sendToKey
                              : _sendToUserValue),
                      const SizedBox(
                        height: 20.0,
                      ),
                      _sendToUserValue == specificRolesKey
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomSelectionDropdownSelectionButton(
                                    onTap: () {
                                      List<String> roles = [
                                        teacherRoleKey,
                                        studentRoleKey,
                                        guardianRoleKey
                                      ];
                                      roles.addAll(state.roles
                                          .map((role) => role.name ?? "-")
                                          .toList());
                                      Utils.showBottomSheet(
                                              child:
                                                  MultiSelectionValueBottomsheet<
                                                          String>(
                                                      values: roles,
                                                      selectedValues:
                                                          _selectedRoles,
                                                      titleKey: roleKey),
                                              context: context)
                                          .then((value) {
                                        if (value != null) {
                                          final updatedSelectedRoles =
                                              List<String>.from(value as List);

                                          _selectedRoles = updatedSelectedRoles;
                                          setState(() {});
                                        }
                                      });
                                    },
                                    titleKey: selectRolesKey),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Wrap(
                                  runSpacing: 10,
                                  spacing: 10,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: _selectedRoles
                                      .map((selectedRole) => Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface),
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomTextContainer(
                                                    textKey: selectedRole),
                                                const SizedBox(
                                                  width: 7.5,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _selectedRoles
                                                        .remove(selectedRole);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .transparent)),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 17.50,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      _sendToUserValue == specificUsersKey
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomSelectionDropdownSelectionButton(
                                    onTap: () {
                                      Get.toNamed(Routes.searchUsersScreen,
                                              arguments: SearchUsersScreen
                                                  .buildArguments(
                                                      selectedUsers:
                                                          _selectedUsers))
                                          ?.then((value) {
                                        if (value != null) {
                                          _selectedUsers =
                                              value as List<UserDetails>;
                                          setState(() {});
                                        }
                                      });
                                    },
                                    titleKey: selectUsersKey),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Wrap(
                                  runSpacing: 10,
                                  spacing: 10,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: _selectedUsers
                                      .map((userDetails) => Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface),
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomTextContainer(
                                                    textKey:
                                                        userDetails.fullName ??
                                                            "-"),
                                                const SizedBox(
                                                  width: 7.5,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _selectedUsers.removeWhere(
                                                        (element) =>
                                                            element.id ==
                                                            userDetails.id);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .transparent)),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 17.50,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      UploadImageOrFileButton(
                        uploadFile: false,
                        includeImageFileOnlyAllowedNote: false,
                        onTap: () {
                          _pickFiles();
                        },
                      ),
                      _pickedFile != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: CustomFileContainer(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                onDelete: () {
                                  _pickedFile = null;
                                  setState(() {});
                                },
                                title: _pickedFile?.name ?? "-",
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
              );
            }
            if (state is RolesFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<RolesCubit>().getRoles();
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
            titleKey: addNotificationKey,
            onBackButtonTap: () {
              if (context.read<SendNotificationCubit>().state
                  is SendNotificationInProgress) {
                return;
              }
              Get.back();
            },
          ),
        ),
      ],
    ));
  }
}
