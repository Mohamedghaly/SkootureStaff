import 'package:eschool_saas_staff/cubits/authentication/sendPasswordResetEmailCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class ForgotPasswordBottomsheet extends StatefulWidget {
  const ForgotPasswordBottomsheet({super.key});

  @override
  State<ForgotPasswordBottomsheet> createState() =>
      _ForgotPasswordBottomsheetState();
}

class _ForgotPasswordBottomsheetState extends State<ForgotPasswordBottomsheet> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _schoolCodeController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    _schoolCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey: forgotPasswordKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            CustomTextFieldContainer(
              prefixWidget: const Icon(Icons.school),
              hintTextKey: schoolCodeKey,
              textEditingController: _schoolCodeController,
            ),
            CustomTextFieldContainer(
              prefixWidget: const Icon(Icons.email_outlined),
              hintTextKey: emailKey,
              textEditingController: _textEditingController,
            ),
            const SizedBox(
              height: 15,
            ),
            BlocConsumer<SendPasswordResetEmailCubit,
                SendPasswordResetEmailState>(
              listener: (context, state) {
                if (state is SendPasswordResetEmailSuccess) {
                  Get.back();
                  Utils.showSnackBar(
                      message: passwordResetLinkSentToYourEmailKey,
                      context: context);
                } else if (state is SendPasswordResetEmailFailure) {
                  Utils.showSnackBar(
                      message: state.errorMessage, context: context);
                }
              },
              builder: (context, state) {
                return PopScope(
                  canPop: state is! SendPasswordResetEmailInProgress,
                  child: CustomRoundedButton(
                    widthPercentage: 1.0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: sendLinkKey,
                    showBorder: false,
                    child: state is SendPasswordResetEmailInProgress
                        ? const CustomCircularProgressIndicator()
                        : null,
                    onTap: () {
                      if (state is SendPasswordResetEmailInProgress) {
                        return;
                      }

                      if (_textEditingController.text.trim().isEmpty) {
                        Utils.showSnackBar(
                            message: pleaseEnterEmailKey, context: context);
                        return;
                      }
                      if (_schoolCodeController.text.trim().isEmpty) {
                        Utils.showSnackBar(
                            message: pleaseEnterSchoolCodeKey,
                            context: context);
                        return;
                      }
                      context
                          .read<SendPasswordResetEmailCubit>()
                          .sendPasswordResetEmail(
                            schoolCode: _schoolCodeController.text.trim(),
                            email: _textEditingController.text.trim(),
                          );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
