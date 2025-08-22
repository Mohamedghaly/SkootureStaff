import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomeContainerAppbar extends StatelessWidget {
  final String profileImage;
  const HomeContainerAppbar({super.key, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom:
                    BorderSide(color: Theme.of(context).colorScheme.tertiary)),
            color: Theme.of(context).colorScheme.surface,
          ),
          height: 70 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: appContentHorizontalPadding,
              right: appContentHorizontalPadding),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: 25,
                backgroundImage: profileImage.isNotEmpty
                    ? CachedNetworkImageProvider(
                        profileImage,
                      )
                    : null,
                child: profileImage.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(
                width: 15.0,
              ),
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextContainer(
                    textKey: hiWelcomebackKey,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.65),
                    ),
                  ),
                  CustomTextContainer(
                    textKey:
                        context.read<AuthCubit>().getUserDetails().fullName ??
                            "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        height: 1.0,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              )),
              BlocBuilder<StaffAllowedPermissionsAndModulesCubit,
                  StaffAllowedPermissionsAndModulesState>(
                builder: (context, state) {
                  if (state is StaffAllowedPermissionsAndModulesFetchSuccess) {
                    return InkWell(
                      radius: 40,
                      onTap: () {
                        Get.toNamed(Routes.notificationsScreen);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.tertiary),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_on_outlined),
                      ),
                    );
                  }

                  if (state is StaffAllowedPermissionsAndModulesFetchFailure) {
                    return InkWell(
                      radius: 40,
                      onTap: () {
                        context.read<AuthCubit>().signOut();
                        Get.offNamed(Routes.loginScreen);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.tertiary),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.login_outlined),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
