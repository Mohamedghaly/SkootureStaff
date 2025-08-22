import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class StaffDetailsScreen extends StatefulWidget {
  final UserDetails staffDetails;
  const StaffDetailsScreen({super.key, required this.staffDetails});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return StaffDetailsScreen(
      staffDetails: arguments['staffDetails'],
    );
  }

  static Map<String, dynamic> buildArguments(
      {required UserDetails staffDetails}) {
    return {"staffDetails": staffDetails};
  }

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  ///[To show call,email button]
  Widget _buildProfileButton(
      {required BuildContext context,
      required double width,
      required bool showBorder,
      required IconData iconData,
      required Color backgroundColor,
      required Function onTap}) {
    return Container(
      decoration: BoxDecoration(
          border: showBorder
              ? BorderDirectional(
                  end:
                      BorderSide(color: Theme.of(context).colorScheme.tertiary))
              : null),
      height: double.maxFinite,
      width: width,
      child: Center(
        child: GestureDetector(
          onTap: () {
            onTap.call();
          },
          child: Container(
            width: 35,
            height: 35,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
            child: Icon(
              iconData, //
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherDetailsTitleAndValueContainer(
      {required String titleKey, required String valyeKey}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextContainer(
          textKey: titleKey,
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.76)),
        ),
        CustomTextContainer(
          textKey: valyeKey,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.staffDetails.isActive()
        ? Theme.of(context)
            .extension<CustomColors>()!
            .totalStaffOverviewBackgroundColor!
        : Theme.of(context)
            .extension<CustomColors>()!
            .totalStudentOverviewBackgroundColor!;
    return Scaffold(
        body: Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                top: Utils.appContentTopScrollPadding(context: context)),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary),
                        top: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary)),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ProfileImageContainer(
                            imageUrl: widget.staffDetails.image ?? "",
                            heightAndWidth: 80,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextContainer(
                                textKey: widget.staffDetails.fullName ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: CustomTextContainer(
                                  textKey: widget.staffDetails.getRoles(),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.76)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextWithFadedBackgroundContainer(
                                  backgroundColor: statusColor.withValues(alpha: 0.1),
                                  textColor: statusColor,
                                  titleKey: widget.staffDetails.isActive()
                                      ? activeKey
                                      : inactiveKey)
                            ],
                          ))
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  height: 80,
                  color: Theme.of(context).colorScheme.surface,
                  child: LayoutBuilder(builder: (context, boxConstraints) {
                    return Row(
                      children: [
                        _buildProfileButton(
                            context: context,
                            width: boxConstraints.maxWidth * (0.5),
                            showBorder: true,
                            iconData: Icons.email_outlined,
                            backgroundColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .totalStudentOverviewBackgroundColor!,
                            onTap: () {
                              Utils.launchEmailLog(
                                  email: widget.staffDetails.email ?? "");
                            }),
                        _buildProfileButton(
                            context: context,
                            width: boxConstraints.maxWidth * (0.5),
                            showBorder: true,
                            iconData: Icons.call,
                            backgroundColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .totalStaffOverviewBackgroundColor!,
                            onTap: () {
                              Utils.launchCallLog(
                                  mobile: widget.staffDetails.mobile ?? "");
                            }),
                      ],
                    );
                  }),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomTextContainer(
                        textKey: staffDetailsKey,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      Divider(
                        color: Theme.of(context).colorScheme.tertiary,
                        height: 30,
                      ),
                      _buildTeacherDetailsTitleAndValueContainer(
                          titleKey: joiningDateKey,
                          valyeKey:
                              (widget.staffDetails.createdAt ?? "").isEmpty
                                  ? "-"
                                  : () {
                                      final parsedDate = Utils.parseDateSafely(widget.staffDetails.createdAt!);
                                      if (parsedDate != null) {
                                        return Utils.formatDate(parsedDate);
                                      }
                                      return widget.staffDetails.createdAt ?? "";
                                    }()),
                      _buildTeacherDetailsTitleAndValueContainer(
                          titleKey: emailKey,
                          valyeKey: widget.staffDetails.email ?? "-"),
                      _buildTeacherDetailsTitleAndValueContainer(
                          titleKey: phoneKey,
                          valyeKey: widget.staffDetails.mobile ?? "-"),
                      _buildTeacherDetailsTitleAndValueContainer(
                          titleKey: dateOfBirthKey,
                          valyeKey: (widget.staffDetails.dob ?? "").isEmpty
                              ? "-"
                              : () {
                                  final parsedDate = Utils.parseDateSafely(widget.staffDetails.dob!);
                                  if (parsedDate != null) {
                                    return Utils.formatDate(parsedDate);
                                  }
                                  return widget.staffDetails.dob ?? "";
                                }()),
                      _buildTeacherDetailsTitleAndValueContainer(
                          titleKey: genderKey,
                          valyeKey: widget.staffDetails.getGender()),
                      _buildTeacherDetailsTitleAndValueContainer(
                          titleKey: salaryKey,
                          valyeKey: widget.staffDetails.staff?.salary
                                  ?.toStringAsFixed(2) ??
                              "-"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: CustomAppbar(titleKey: staffDetailsKey),
        ),
      ],
    ));
  }
}
