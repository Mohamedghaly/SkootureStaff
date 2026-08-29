import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTabContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/tabBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';

class StudentProfileScreen extends StatefulWidget {
  final StudentDetails studentDetails;
  final SessionYear sessionYear;
  final ClassSection classSection;
  const StudentProfileScreen(
      {super.key,
      required this.studentDetails,
      required this.sessionYear,
      required this.classSection});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return StudentProfileScreen(
      classSection: arguments['classSection'],
      sessionYear: arguments['sessionYear'],
      studentDetails: arguments['studentDetails'],
    );
  }

  static Map<String, dynamic> buildArguments(
      {required StudentDetails studentDetails,
      required SessionYear sessionYear,
      required ClassSection classSection}) {
    return {
      "classSection": classSection,
      "studentDetails": studentDetails,
      "sessionYear": sessionYear
    };
  }

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late String _selectedTabTitleKey = generalKey;

  void changeTab(String value) {
    setState(() {
      _selectedTabTitleKey = value;
    });
  }

  Widget _buildStudentDetailsTitleAndValueContainer(
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

  /// Handle file link opening using existing Utils method
  void _openFileLink(String url) {
    Utils.openLinkInBrowser(
      url: url,
      context: context,
    );
  }

  /// Build extra student details section
  Widget _buildExtraStudentDetails() {
    final extraDetails = widget.studentDetails.extraStudentDetails;

    // Only show if there are extra details with data
    if (extraDetails == null || extraDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter out details without data
    final detailsWithData = extraDetails
        .where((detail) => detail.data != null && detail.data!.isNotEmpty)
        .toList();

    if (detailsWithData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 25),
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          padding: EdgeInsets.all(appContentHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              CustomTextContainer(
                textKey: "Additional Details",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 15),
              // List of extra details
              ...detailsWithData.map((detail) {
                final isFile = detail.isFileField();
                final fileUrl = detail.getFileUrl();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field Label (using form_field name or fallback to ID)
                      CustomTextContainer(
                        textKey: detail.getFieldName(),
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.76),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Field Value or File Link
                      if (isFile && fileUrl != null)
                        GestureDetector(
                          onTap: () => _openFileLink(fileUrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: CustomTextContainer(
                                    textKey: detail.data?.split('/').last ??
                                        'View File',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        CustomTextContainer(
                          textKey: detail.data ?? "-",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianDetails() {
    final guardian = widget.studentDetails.student?.guardian;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
              border:
                  Border.all(color: Theme.of(context).colorScheme.tertiary)),
          height: 100,
          child: Row(
            children: [
              ProfileImageContainer(
                imageUrl: guardian?.image ?? "",
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextContainer(
                    textKey: guardian?.fullName ?? "-",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          width: double.maxFinite,
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.all(appContentHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentDetailsTitleAndValueContainer(
                  titleKey: emailKey, valyeKey: guardian?.email ?? "-"),
              Row(
                children: [
                  Expanded(
                    child: _buildStudentDetailsTitleAndValueContainer(
                        titleKey: mobileKey, valyeKey: guardian?.mobile ?? "-"),
                  ),
                  CustomRoundedButton(
                    height: 35,
                    widthPercentage: 0.3,
                    textSize: 14.0,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    buttonTitle: callNowKey,
                    showBorder: false,
                    onTap: () {
                      Utils.launchCallLog(mobile: guardian?.mobile ?? "");
                    },
                  ),
                ],
              ),
              _buildStudentDetailsTitleAndValueContainer(
                  titleKey: genderKey, valyeKey: guardian?.getGender() ?? "-"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentGeneralDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary))),
          height: 100,
          child: Row(
            children: [
              ProfileImageContainer(
                imageUrl: widget.studentDetails.image ?? "",
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextContainer(
                    textKey: widget.studentDetails.fullName ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                  CustomTextContainer(
                    textKey:
                        "GR No : ${widget.studentDetails.student?.admissionNo ?? '-'}",
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.76)),
                  ),
                ],
              )),
            ],
          ),
        ),
        Container(
          width: double.maxFinite,
          height: 80,
          padding: EdgeInsets.all(appContentHorizontalPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextContainer(
                      textKey: emergencyContactKey,
                      style: TextStyle(
                          fontSize: 13.0,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.76)),
                    ),
                    CustomTextContainer(
                      textKey: widget.studentDetails.mobile ?? "-",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
              CustomRoundedButton(
                height: 35,
                widthPercentage: 0.3,
                textSize: 14.0,
                backgroundColor: Theme.of(context).colorScheme.error,
                buttonTitle: callNowKey,
                showBorder: false,
                onTap: () {
                  Utils.launchCallLog(
                      mobile: widget.studentDetails.mobile ?? "-");
                },
              ),
            ],
          ),
        ),
        // Combined Student Diary Container with Add Note Button
        // Only show if user has view or create permission
        Builder(
          builder: (context) {
            final hasViewPermission = context
                .read<StaffAllowedPermissionsAndModulesCubit>()
                .isPermissionGiven(permission: viewStudentDiaryPermissionKey);

            final hasCreatePermission = context
                .read<StaffAllowedPermissionsAndModulesCubit>()
                .isPermissionGiven(permission: createStudentDiaryPermissionKey);

            // Only show the container if user has at least one permission
            if (!hasViewPermission && !hasCreatePermission) {
              return const SizedBox();
            }

            return Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // Student Diary Section - Only show if has view permission
                      if (hasViewPermission) ...[
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              Routes.studentDiaryScreen,
                              arguments: {
                                'studentId': widget.studentDetails.id
                              },
                            );
                          },
                          child: Row(
                            children: [
                              // Notebook Icon with circular background
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    "assets/images/note_book.svg",
                                    width: 30,
                                    height: 30,
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Text Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextContainer(
                                      textKey: studentDiaryKey,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    CustomTextContainer(
                                      textKey: manageStudentDiaryKey,
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow Icon with circular background
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Utils.isRTLEnabled(context)
                                        ? CupertinoIcons.arrow_left
                                        : CupertinoIcons.arrow_right,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add spacing if both sections are visible
                        if (hasCreatePermission) const SizedBox(height: 20),
                      ],

                      // Add Note Button - Only show if has create permission
                      if (hasCreatePermission)
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              Routes.addNoteScreen,
                              arguments: {
                                'selectedStudents': [widget.studentDetails],
                                'classSection': widget.classSection,
                                'sessionYear': widget.sessionYear,
                              },
                            );
                          },
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // White circular background with black plus icon
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CustomTextContainer(
                                  textKey: addNoteKey,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          padding: EdgeInsets.all(appContentHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentDetailsTitleAndValueContainer(
                  titleKey: statusKey,
                  valyeKey: widget.studentDetails.isActive()
                      ? activeKey
                      : inactiveKey),
              _buildStudentDetailsTitleAndValueContainer(
                  titleKey: sessionYearKey,
                  valyeKey: widget.sessionYear.name ?? "-"),
              _buildStudentDetailsTitleAndValueContainer(
                titleKey: admissionDateKey,
                valyeKey:
                    (widget.studentDetails.student?.admissionDate ?? "").isEmpty
                        ? "-"
                        : widget.studentDetails.student!.admissionDate ?? "",
              ),
              _buildStudentDetailsTitleAndValueContainer(
                  titleKey: classSectionKey,
                  valyeKey: widget.classSection.fullName ?? "-"),
              _buildStudentDetailsTitleAndValueContainer(
                  titleKey: rollNoKey,
                  valyeKey:
                      widget.studentDetails.student?.rollNumber?.toString() ??
                          "-"),
              _buildStudentDetailsTitleAndValueContainer(
                  titleKey: genderKey,
                  valyeKey: widget.studentDetails.getGender()),
              _buildStudentDetailsTitleAndValueContainer(
                  titleKey: mobileKey,
                  valyeKey: widget.studentDetails.mobile ?? "-"),
            ],
          ),
        ),
        // Extra student details section
        _buildExtraStudentDetails(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                left: appContentHorizontalPadding,
                right: appContentHorizontalPadding,
                top: Utils.appContentTopScrollPadding(context: context) + 100),
            child: AnimatedSwitcher(
              duration: tabDuration,
              child: _selectedTabTitleKey == generalKey
                  ? _buildStudentGeneralDetails()
                  : _buildGuardianDetails(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const CustomAppbar(titleKey: studentProfileKey),
              TabBackgroundContainer(
                  child: LayoutBuilder(builder: (conext, boxConstraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTabContainer(
                        titleKey: generalKey,
                        isSelected: _selectedTabTitleKey == generalKey,
                        width: boxConstraints.maxWidth * (0.48),
                        onTap: changeTab),
                    CustomTabContainer(
                        titleKey: guardianKey,
                        isSelected: _selectedTabTitleKey == guardianKey,
                        width: boxConstraints.maxWidth * (0.48),
                        onTap: changeTab),
                  ],
                );
              }))
            ],
          ),
        )
      ],
    ));
  }
}
