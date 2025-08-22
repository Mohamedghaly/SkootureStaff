import 'package:eschool_saas_staff/cubits/authentication/changePasswordCubic.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/showHidePasswordButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => ChangePasswoedCubit(),
      child: const ChangePasswordScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  late bool _hideOldPassword = true;
  late bool _hideNewPassword = true;
  late bool _hideConfirmPassword = true;

  @override
  void dispose() {
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Widget _buildUpdatePasswordButton(ChangePasswordState state) {
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
            buttonTitle: updatePasswordKey,
            showBorder: false,
            child: state is ChangePasswordProgress
                ? const CustomCircularProgressIndicator()
                : null,
            onTap: () {
              if (state is ChangePasswordProgress) {
                return;
              }
              if (oldPassword.text.trim().isEmpty) {
                Utils.showSnackBar(
                    message: pleaseEnterOldPasswordKey, context: context);
                return;
              } else if (newPassword.text.trim().isEmpty) {
                Utils.showSnackBar(
                    message: pleaseEnterNewPasswordKey, context: context);
                return;
              } else if (confirmPassword.text.trim().isEmpty) {
                Utils.showSnackBar(
                    message: pleaseEnterConfirmPasswordKey, context: context);
                return;
              } else if (confirmPassword.text.trim() !=
                  newPassword.text.trim()) {
                Utils.showSnackBar(
                    message: passwordAreNotMatchKey, context: context);
                return;
              }
              context.read<ChangePasswoedCubit>().changePassword(
                  oldPassword: oldPassword.text.trim(),
                  newPassword: newPassword.text.trim(),
                  confirmPassword: confirmPassword.text.trim());
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<ChangePasswoedCubit, ChangePasswordState>(
            listener: (context, state) {
      if (state is ChangePasswordSuccess) {
        Get.back();
        Utils.showSnackBar(message: state.successMessage, context: context);
      } else if (state is ChangePasswordFailure) {
        Utils.showSnackBar(message: state.errorMessage, context: context);
      }
    }, builder: (context, state) {
      return PopScope(
        canPop: state is! ChangePasswordProgress,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: Utils.appContentTopScrollPadding(context: context) +
                        25),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).colorScheme.surface,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  child: Column(
                    children: [
                      CustomTextFieldContainer(
                        textEditingController: oldPassword,
                        hideText: _hideOldPassword,
                        hintTextKey: oldPasswordKey,
                        suffixWidget: ShowHidePasswordButton(
                          hidePassword: _hideOldPassword,
                          onTapButton: () {
                            setState(() {
                              _hideOldPassword = !_hideOldPassword;
                            });
                          },
                        ),
                      ),
                      CustomTextFieldContainer(
                        textEditingController: newPassword,
                        hideText: _hideNewPassword,
                        hintTextKey: newPasswordKey,
                        suffixWidget: ShowHidePasswordButton(
                          hidePassword: _hideNewPassword,
                          onTapButton: () {
                            setState(() {
                              _hideNewPassword = !_hideNewPassword;
                            });
                          },
                        ),
                      ),
                      CustomTextFieldContainer(
                        textEditingController: confirmPassword,
                        hideText: _hideConfirmPassword,
                        hintTextKey: confirmPasswordKey,
                        suffixWidget: ShowHidePasswordButton(
                          hidePassword: _hideConfirmPassword,
                          onTapButton: () {
                            setState(() {
                              _hideConfirmPassword = !_hideConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(child: _buildUpdatePasswordButton(state)),
            Align(
                alignment: Alignment.topCenter,
                child: CustomAppbar(
                  titleKey: changePasswordKey,
                  onBackButtonTap: () {
                    if (state is ChangePasswordProgress) {
                      return;
                    }
                    Get.back();
                  },
                )),
          ],
        ),
      );
    }));
  }
}
