import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffProfile/widgets/assignTaskBottomButton.dart';
import 'package:eschool_saas_staff/ui/screens/staffProfile/widgets/profileTabBar.dart';
import 'package:eschool_saas_staff/ui/screens/staffProfile/widgets/profileTasksTab.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherProfileScreen extends StatefulWidget {
  final UserDetails teacher;
  const TeacherProfileScreen({super.key, required this.teacher});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return TeacherProfileScreen(
      teacher: arguments['teacher'] as UserDetails,
    );
  }

  static Map<String, dynamic> buildArguments(
      {required UserDetails userDetails}) {
    return {"teacher": userDetails};
  }

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  int _selectedTabIndex = 0;

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
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
            child: Icon(
              iconData,
              size: 24,
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
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.76)),
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

  /// Builds the "Details" tab content — existing teacher details.
  Widget _buildDetailsTab() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomTextContainer(
            textKey: teacherDetailsKey,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          Divider(
            color: Theme.of(context).colorScheme.tertiary,
            height: 30,
          ),
          _buildTeacherDetailsTitleAndValueContainer(
              titleKey: joiningDateKey,
              valyeKey: () {
                final parsedDate =
                    Utils.parseDateSafely(widget.teacher.createdAt!);
                if (parsedDate != null) {
                  return Utils.formatDate(parsedDate);
                }
                return widget.teacher.createdAt ?? "";
              }()),
          _buildTeacherDetailsTitleAndValueContainer(
              titleKey: emailKey, valyeKey: widget.teacher.email ?? ""),
          _buildTeacherDetailsTitleAndValueContainer(
              titleKey: phoneKey, valyeKey: widget.teacher.mobile ?? ""),
          _buildTeacherDetailsTitleAndValueContainer(
              titleKey: dateOfBirthKey,
              valyeKey: (widget.teacher.dob ?? "").isEmpty
                  ? "-"
                  : () {
                      final parsedDate =
                          Utils.parseDateSafely(widget.teacher.dob!);
                      if (parsedDate != null) {
                        return Utils.formatDate(parsedDate);
                      }
                      return widget.teacher.dob ?? "";
                    }()),
          _buildTeacherDetailsTitleAndValueContainer(
              titleKey: genderKey, valyeKey: widget.teacher.getGender()),
          _buildTeacherDetailsTitleAndValueContainer(
              titleKey: qualificationKey,
              valyeKey: widget.teacher.staff?.qualification ?? "-"),
          _buildTeacherDetailsTitleAndValueContainer(
              titleKey: salaryKey,
              valyeKey:
                  widget.teacher.staff?.salary?.toStringAsFixed(2) ?? "-"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF7F9FF),
        bottomNavigationBar: AssignTaskBottomButton(
          onTap: () {},
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: Utils.appContentTopScrollPadding(context: context)),
                child: ColoredBox(
                  color: const Color(0xFFF7F9FF),
                  child: Column(
                    children: [
                      // Profile header
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(appContentHorizontalPadding),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              top: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ProfileImageContainer(
                                    imageUrl: widget.teacher.image ?? ""),
                                const SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextContainer(
                                      textKey: widget.teacher.fullName ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    CustomTextContainer(
                                      textKey: widget.teacher.isActive()
                                          ? activeKey
                                          : inactiveKey,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ))
                              ],
                            )
                          ],
                        ),
                      ),

                      // Action icons row
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(appContentHorizontalPadding),
                        height: 80,
                        color: Theme.of(context).colorScheme.surface,
                        child:
                            LayoutBuilder(builder: (context, boxConstraints) {
                          final iconWidth = boxConstraints.maxWidth / 3;
                          return Row(
                            children: [
                              _buildProfileButton(
                                  context: context,
                                  width: iconWidth,
                                  showBorder: true,
                                  iconData: Icons.chat_outlined,
                                  backgroundColor: const Color(0xFF518EF4),
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.chatScreen,
                                      arguments: ChatScreen.buildArguments(
                                        receiverId: widget.teacher.id ?? 0,
                                        receiverName:
                                            widget.teacher.fullName ?? "",
                                        receiverImage:
                                            widget.teacher.image ?? "",
                                      ),
                                    );
                                  }),
                              _buildProfileButton(
                                  context: context,
                                  width: iconWidth,
                                  showBorder: true,
                                  iconData: Icons.email_outlined,
                                  backgroundColor: const Color(0xFFED7483),
                                  onTap: () {
                                    Utils.launchEmailLog(
                                        email: widget.teacher.email ?? "");
                                  }),
                              _buildProfileButton(
                                  context: context,
                                  width: iconWidth,
                                  showBorder: false,
                                  iconData: Icons.call,
                                  backgroundColor: const Color(0xFF57CC99),
                                  onTap: () {
                                    Utils.launchCallLog(
                                        mobile: widget.teacher.mobile ?? "");
                                  }),
                            ],
                          );
                        }),
                      ),

                      const SizedBox(height: 16),

                      // Tab bar: Details / Tasks
                      ProfileTabBar(
                        selectedIndex: _selectedTabIndex,
                        onTabSelected: (index) {
                          setState(() => _selectedTabIndex = index);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tab content
                      if (_selectedTabIndex == 0) _buildDetailsTab(),
                      if (_selectedTabIndex == 1)
                        ProfileTasksTab(userId: widget.teacher.id),
                    ],
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(titleKey: staffProfileKey),
            ),
          ],
        ));
  }
}
