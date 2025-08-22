import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/academicsContainer/widgets/staffAcademicsContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/academicsContainer/widgets/teacherAcademicsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AcademicsContainer extends StatelessWidget {
  const AcademicsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: BlocBuilder<StaffAllowedPermissionsAndModulesCubit,
              StaffAllowedPermissionsAndModulesState>(
            builder: (context, state) {
              if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
                return SingleChildScrollView(
                    padding: EdgeInsetsDirectional.only(
                        top:
                            Utils.appContentTopScrollPadding(context: context) +
                                20,
                        end: appContentHorizontalPadding,
                        start: appContentHorizontalPadding,
                        bottom: 100),
                    child: context.read<AuthCubit>().isTeacher()
                        ? const TeacherAcademicsContainer()
                        : const StaffAcademicsContainer());
              } else if (state
                  is StaffAllowedPermissionsAndModulesFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<StaffAllowedPermissionsAndModulesCubit>()
                          .getPermissionAndAllowedModules();
                    },
                  ),
                );
              } else {
                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            },
          ),
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: CustomAppbar(
            showBackButton: false,
            titleKey: academicsKey,
          ),
        )
      ],
    );
  }
}
