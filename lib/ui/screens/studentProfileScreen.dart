
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
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
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
        const SizedBox(
          height: 20,
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
