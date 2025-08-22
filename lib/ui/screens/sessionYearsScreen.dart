import 'package:eschool_saas_staff/cubits/academics/sessionYearsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SessionYearsScreen extends StatefulWidget {
  const SessionYearsScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => SessionYearsCubit(),
      child: const SessionYearsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<SessionYearsScreen> createState() => _SessionYearsScreenState();
}

class _SessionYearsScreenState extends State<SessionYearsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SessionYearsCubit>().getSessionYears();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(titleKey: sessionYearKey),
      body: BlocBuilder<SessionYearsCubit, SessionYearsState>(
          builder: (context, state) {
        if (state is SessionYearsFetchSuccess) {
          if (state.sessionYears.isEmpty) {
            return Center(
              child: noDataContainer(
                titleKey: noSessionYearsKey,
              ),
            );
          }
          return ListView.builder(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              itemCount: state.sessionYears.length,
              itemBuilder: (context, index) {
                final sessionYear = state.sessionYears[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: appContentHorizontalPadding),
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    title: CustomTextContainer(textKey: sessionYear.name ?? ""),
                    subtitle: sessionYear.isThisDefault()
                        ? const CustomTextContainer(textKey: "Default")
                        : null,
                  ),
                );
              });
        }
        if (state is SessionYearsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                context.read<SessionYearsCubit>().getSessionYears();
              },
            ),
          );
        }
        return Center(
          child: CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }),
    );
  }
}
