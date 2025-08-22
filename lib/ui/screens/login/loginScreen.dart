import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/sendPasswordResetEmailCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/signInCubit.dart';
import 'package:eschool_saas_staff/ui/screens/login/widgets/forgotPasswordBottomsheet.dart';

import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/showHidePasswordButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => SignInCubit(),
        child: const LoginScreen(),
      );

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _hidePassword = true;
  var canPop = false;

  late final _schoolCodeController = TextEditingController();

  late final TextEditingController _emailTextEditingController =
      TextEditingController();

  late final TextEditingController _passwordTextEditingController =
      TextEditingController();

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: SafeArea(
        child: CustomTextButton(
            textStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary, fontSize: 16.0),
            buttonTextKey: forgotPasswordKey,
            onTapButton: () {
              if (context.read<SignInCubit>().state is SignInInProgress) {
                return;
              }
              Utils.showBottomSheet(
                  child: BlocProvider(
                    create: (context) => SendPasswordResetEmailCubit(),
                    child: const ForgotPasswordBottomsheet(),
                  ),
                  context: context);
            }),
      ),
    );
  }

  Widget _buildTermsConditionAndPrivacyPolicyContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomTextContainer(
            textKey: bySignInYouAgreeToOurKey,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextButton(
                onTapButton: () {
                  if (context.read<SignInCubit>().state is SignInInProgress) {
                    return;
                  }
                  Get.toNamed(Routes.termsAndConditionScreen);
                },
                buttonTextKey: termsAndConditionKey,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: CustomTextContainer(textKey: andKey),
              ),
              CustomTextButton(
                onTapButton: () {
                  if (context.read<SignInCubit>().state is SignInInProgress) {
                    return;
                  }

                  Get.toNamed(Routes.privacyPolicyScreen);
                },
                buttonTextKey: privacyPolicyKey,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  void _onWillPop() {
    setState(() {
      canPop = true;
    });
    Utils.showSnackBar(
      message: pressbackagaintoexitKey,
      context: context,
    ); // Do not exit the app
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        canPop = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onWillPop();
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                    left: appContentHorizontalPadding,
                    right: appContentHorizontalPadding,
                    top: MediaQuery.of(context).padding.top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 75),
                    const CustomTextContainer(
                      textKey: letSignInKey,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    const CustomTextContainer(
                      textKey: signInScreenSubTitleKey,
                      style: TextStyle(fontSize: 16.0, height: 1.1),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFieldContainer(
                      textEditingController: _schoolCodeController,
                      hintTextKey: schoolCodeKey,
                    ),
                    CustomTextFieldContainer(
                      prefixWidget: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textEditingController: _emailTextEditingController,
                      hintTextKey: emailKey,
                    ),
                    CustomTextFieldContainer(
                      prefixWidget: Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textEditingController: _passwordTextEditingController,
                      hintTextKey: passwordKey,
                      hideText: _hidePassword,
                      suffixWidget: ShowHidePasswordButton(
                          hidePassword: _hidePassword,
                          onTapButton: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          }),
                    ),
                    SafeArea(child: _buildForgotPasswordButton()),
                    const SizedBox(height: 25),
                    BlocConsumer<SignInCubit, SignInState>(
                      listener: (context, state) {
                        if (state is SignInSuccess) {
                          context.read<AuthCubit>().authenticateUser(
                                authToken: state.authToken,
                                schoolCode: state.schoolCode,
                                userDetails: state.userDetails,
                              );
                          Get.offNamed(Routes.homeScreen);
                        } else if (state is SignInFailure) {
                          Utils.showSnackBar(
                              message: state.errorMessage, context: context);
                        }
                      },
                      builder: (context, state) {
                        return PopScope(
                          canPop: state is! SignInInProgress,
                          child: CustomRoundedButton(
                            widthPercentage: 1.0,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            buttonTitle: signInKey,
                            showBorder: false,
                            child: state is SignInInProgress
                                ? const CustomCircularProgressIndicator()
                                : null,
                            onTap: () {
                              if (state is SignInInProgress) {
                                return;
                              }

                              if (_schoolCodeController.text.trim().isEmpty) {
                                Utils.showSnackBar(
                                  message: pleaseEnterSchoolCodeKey,
                                  context: context,
                                );
                                return;
                              }

                              if (_emailTextEditingController.text
                                  .trim()
                                  .isEmpty) {
                                Utils.showSnackBar(
                                    message: pleaseEnterEmailKey,
                                    context: context);
                                return;
                              }
                              if (_passwordTextEditingController.text
                                  .trim()
                                  .isEmpty) {
                                Utils.showSnackBar(
                                    message: pleaseEnterPasswordKey,
                                    context: context);
                                return;
                              }

                              context.read<SignInCubit>().signInUser(
                                    email:
                                        _emailTextEditingController.text.trim(),
                                    password: _passwordTextEditingController
                                        .text
                                        .trim(),
                                    schoolCode:
                                        _schoolCodeController.text.trim(),
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(child: _buildTermsConditionAndPrivacyPolicyContainer()),
            ],
          )),
    );
  }
}
