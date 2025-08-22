import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/appLocalizationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menuTile.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/menusWithTitleContainer.dart';
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

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({super.key});

  String? getRoles(BuildContext context) {
    if (!context.read<AuthCubit>().isTeacher()) {
      return context.read<AuthCubit>().getUserDetails().getRoles();
    } else {
      return Utils.getTranslatedLabel(teacherKey);
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
                        onTap: () {
                          Get.toNamed(Routes.editProfileScreen);
                        },
                        titleKey: editProfileKey),
                    MenuTile(
                        iconImageName: "change_password.svg",
                        onTap: () {
                          Get.toNamed(Routes.changePasswordScreen);
                        },
                        titleKey: changePasswordKey),
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
                  ], title: personalSettingsKey),
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
                      ProfileImageContainer(
                        imageUrl:
                            context.read<AuthCubit>().getUserDetails().image ??
                                "",
                        heightAndWidth: 80,
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
                            style: const TextStyle(height: 1.1),
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
