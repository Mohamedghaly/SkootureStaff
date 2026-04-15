import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/appLocalizationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menuTile.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menusWithTitleContainer.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionTile.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/appLanguages.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class ProfileContainer extends StatefulWidget {
  const ProfileContainer({super.key});

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  String? getRoles(BuildContext context) {
    if (!context.read<AuthCubit>().isTeacher()) {
      return context.read<AuthCubit>().getUserDetails().getRoles();
    } else {
      return Utils.getTranslatedLabel(teacherKey);
    }
  }

  void _navigateToEditProfile() async {
    final result = await Get.toNamed(Routes.editProfileScreen);

    // Check if widget is still mounted before showing snackbar
    if (!mounted) return;

    if (result != null) {
      // Use ScaffoldMessenger which is more reliable than GetX snackbar
      // ScaffoldMessenger works with the app's MaterialApp and doesn't need Overlay
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomTextContainer(
            textKey: result.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15.5,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, authstate) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                  top: Utils.appContentTopScrollPadding(context: context) + 145,
                  end: appContentHorizontalPadding,
                  start: appContentHorizontalPadding,
                  bottom: 100),
              child: Column(
                children: [
                  MenusWithTitleContainer(menus: [
                    MenuTile(
                        iconImageName: "edit_profile.svg",
                        onTap: _navigateToEditProfile,
                        titleKey: editProfileKey),
                    MenuTile(
                        iconImageName: "change_password.svg",
                        onTap: () {
                          Get.toNamed(Routes.changePasswordScreen);
                        },
                        titleKey: changePasswordKey),
                    MenuTile(
                        iconData: Icons.notifications_outlined,
                        onTap: () {
                          Get.toNamed(Routes.notificationsScreen);
                        },
                        titleKey: notificationsKey),
                    if (context.read<AuthCubit>().isDriver()) ...[
                      MenuTile(
                          iconImageName: "leave_overview.svg",
                          onTap: () {
                            Get.toNamed(Routes.leavesScreen,
                                arguments: LeavesScreen.buildArguments(
                                    showMyLeaves: true));
                          },
                          titleKey: leaveOverviewKey),
                      MenuTile(
                          iconImageName: "expenses.svg",
                          onTap: () {
                            Get.toNamed(Routes.myExpenseScreen);
                          },
                          titleKey: myExpensesKey),
                      MenuTile(
                        iconImageName: "view_attendance.svg",
                        titleKey: myAttendanceKey,
                        onTap: () {
                          Get.toNamed(Routes.teacherMyAttendanceScreen);
                        },
                      ),
                    ],
                  ], title: personalSettingsKey),
                  MenusWithTitleContainer(menus: [
                    MenuTile(
                        iconImageName: "change_language.svg",
                        onTap: () {
                          Utils.showBottomSheet(
                              child: const AppLanguagesBottomsheet(),
                              context: context);
                        },
                        titleKey: changeLanguageKey),
                    MenuTile(
                        iconImageName: "about_us.svg",
                        onTap: () {
                          Get.toNamed(Routes.aboutUsScreen);
                        },
                        titleKey: aboutUsKey),
                    MenuTile(
                        iconImageName: "contact_us.svg",
                        onTap: () {
                          Get.toNamed(Routes.contactUsScreen);
                        },
                        titleKey: contactUsKey),
                    MenuTile(
                        iconImageName: "privacy_policy.svg",
                        onTap: () {
                          Get.toNamed(Routes.privacyPolicyScreen);
                        },
                        titleKey: privacyPolicyKey),
                    MenuTile(
                        iconImageName: "terms_and_conditions.svg",
                        onTap: () {
                          Get.toNamed(Routes.termsAndConditionScreen);
                        },
                        titleKey: termsAndConditionKey),
                    if (context
                        .read<AppConfigurationCubit>()
                        .getAppLink()
                        .isNotEmpty) ...[
                      MenuTile(
                          iconImageName: "rate_us.svg",
                          onTap: () {
                            Utils.openLinkInBrowser(
                                url: context
                                    .read<AppConfigurationCubit>()
                                    .getAppLink(),
                                context: context);
                          },
                          titleKey: rateUsKey),
                      MenuTile(
                          iconImageName: "share.svg",
                          onTap: () {
                            Utils.openLinkInBrowser(
                                isShareAppLink: true,
                                url: context
                                    .read<AppConfigurationCubit>()
                                    .getAppLink(),
                                context: context);
                          },
                          titleKey: shareAppKey),
                    ],
                  ], title: moreSettingsKey),
                  CustomRoundedButton(
                    widthPercentage: 1.0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    borderColor: Theme.of(context).colorScheme.error,
                    buttonTitle: logoutKey,
                    titleColor: Theme.of(context).colorScheme.error,
                    showBorder: true,
                    onTap: () {
                      showDialog(
                              context: context,
                              builder: (_) => const LogoutConfirmationDialog())
                          .then((value) {
                        final logoutUser = (value as bool?) ?? false;
                        if (logoutUser) {
                          if (context.mounted) {
                            context.read<AuthCubit>().signOut();
                            Get.offNamed(Routes.loginScreen);
                          }
                        }
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const CustomAppbar(
                  titleKey: profileKey,
                  showBackButton: false,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary))),
                  height: 120,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: (context
                                        .read<AuthCubit>()
                                        .getUserDetails()
                                        .image ??
                                    "")
                                .isNotEmpty
                            ? () => Utils.showImagePreview(
                                  context: context,
                                  imageUrl: context
                                          .read<AuthCubit>()
                                          .getUserDetails()
                                          .image ??
                                      "",
                                  heroTag: 'profile_container_image_preview',
                                )
                            : null,
                        child: Hero(
                          tag: 'profile_container_image_preview',
                          child: ProfileImageContainer(
                            imageUrl: context
                                    .read<AuthCubit>()
                                    .getUserDetails()
                                    .image ??
                                "",
                            heightAndWidth: 80,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextContainer(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textKey: context
                                    .read<AuthCubit>()
                                    .getUserDetails()
                                    .fullName ??
                                "-",
                            style: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.w600),
                          ),
                          CustomTextContainer(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textKey:
                                "${Utils.getTranslatedLabel(roleKey)} : ${getRoles(context)}",
                            style: const TextStyle(height: 1.1),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          CustomTextContainer(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textKey:
                                "${context.read<AuthCubit>().getUserDetails().school?.name ?? "-"} (${context.read<AuthCubit>().getUserDetails().school?.code ?? "-"})",
                            style: const TextStyle(height: 1.5),
                          )
                        ],
                      )),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}

class AppLanguagesBottomsheet extends StatelessWidget {
  const AppLanguagesBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: changeLanguageKey,
        child: BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              child: Column(
                children: appLanguages
                    .map((language) => FilterSelectionTile(
                        onTap: () {
                          context
                              .read<AppLocalizationCubit>()
                              .changeLanguage(language.languageCode);
                        },
                        isSelected: state.language.languageCode ==
                            language.languageCode,
                        title: language.languageName))
                    .toList(),
              ),
            );
          },
        ));
  }
}

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const CustomTextContainer(
        textKey: sureToLogoutKey,
      ),
      actions: [
        CupertinoButton(
            child: Text(Utils.getTranslatedLabel(yesKey)),
            onPressed: () {
              Get.back(result: true);
            }),
        CupertinoButton(
            child: Text(Utils.getTranslatedLabel(noKey)),
            onPressed: () {
              Get.back(result: false);
            }),
      ],
    );
  }
}
