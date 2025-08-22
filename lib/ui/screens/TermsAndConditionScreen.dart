import 'package:eschool_saas_staff/cubits/settingCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/route_manager.dart';

class TermsAndConditionScreen extends StatefulWidget {
  const TermsAndConditionScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: const TermsAndConditionScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  @override
  void initState() {
    context.read<SettingsCubit>().getSettings("teacher_terms_condition");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<SettingsCubit, SettingsState>(
            listener: (context, state) {
      if (state is SettingsFailure) {
        Utils.showSnackBar(message: state.errorMessage, context: context);
      }
    }, builder: (context, state) {
      return PopScope(
        canPop: state is! SettingsProgress,
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
                    child: state is SettingsSuccess
                        ? state.data.isEmpty
                            ? const noDataContainer(
                                titleKey: noTermsAndConditionKey,
                              )
                            : HtmlWidget(
                                state.data,
                              )
                        : const CustomCircularProgressIndicator()),
              ),
            ),
            Align(
                alignment: Alignment.topCenter,
                child: CustomAppbar(
                  titleKey: termsAndConditionKey,
                  onBackButtonTap: () {
                    if (state is SettingsProgress) {
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
