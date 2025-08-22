import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/data/models/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendenceItemContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class StudentAttendanceContainer extends StatefulWidget {
  final List<StudentAttendance> studentAttendances;
  final bool isForAddAttendance;
  final Function(
      List<({StudentAttendanceStatus status, int studentId})>
          attendanceStatuses)? onStatusChanged;
  const StudentAttendanceContainer(
      {super.key,
      required this.isForAddAttendance,
      required this.studentAttendances,
      this.onStatusChanged});

  @override
  State<StudentAttendanceContainer> createState() =>
      _StudentAttendanceContainerState();
}

class _StudentAttendanceContainerState
    extends State<StudentAttendanceContainer> {
  late List<StudentAttendanceStatus> allAttendanceStatuses = widget
      .studentAttendances
      .map((e) => e.isPresent()
          ? StudentAttendanceStatus.present
          : StudentAttendanceStatus.absent)
      .toList();

  @override
  void initState() {
    if (widget.onStatusChanged != null) {
      //passing initially filled values
      widget.onStatusChanged!(
        List.generate(
          widget.studentAttendances.length,
          (index) {
            return (
              status: allAttendanceStatuses[index],
              studentId: widget.studentAttendances[index].studentDetails
                      ?.student?.userId ??
                  0
            );
          },
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 45,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    topLeft: Radius.circular(5.0)),
                color: Theme.of(context).colorScheme.tertiary),
            padding: EdgeInsets.symmetric(
                horizontal: appContentHorizontalPadding, vertical: 10),
            child: LayoutBuilder(builder: (context, boxConstraints) {
              const titleStyle =
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600);
              return Row(
                children: [
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.2),
                    child: const CustomTextContainer(
                      textKey: rollNoKey,
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.6),
                    child: const CustomTextContainer(
                      textKey: nameKey,
                      style: titleStyle,
                    ),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.2),
                    child: const CustomTextContainer(
                      textKey: statusKey,
                      style: titleStyle,
                    ),
                  ),
                ],
              );
            }),
          ),
          ...List.generate(widget.studentAttendances.length, (index) {
            return StudentAttendanceItemContainer(
              studentDetails: widget.studentAttendances[index].studentDetails ??
                  StudentDetails.fromJson({}),
              showStatusPicker: widget.isForAddAttendance,
              isPresent: widget.studentAttendances[index].isPresent(),
              onChangeAttendance: (StudentAttendanceStatus status) {
                allAttendanceStatuses[index] = status;
                if (widget.onStatusChanged != null) {
                  widget.onStatusChanged!(
                    List.generate(
                      widget.studentAttendances.length,
                      (index) {
                        return (
                          status: allAttendanceStatuses[index],
                          studentId: widget.studentAttendances[index]
                                  .studentDetails?.student?.userId ??
                              0
                        );
                      },
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
