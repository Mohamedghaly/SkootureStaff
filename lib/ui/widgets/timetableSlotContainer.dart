import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class TimetableSlotContainer extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String subjectName;
  final bool isForClass;
  final String? teacherName;
  final String note;
  final String? classSectionName;

  const TimetableSlotContainer(
      {super.key,
      required this.startTime,
      required this.endTime,
      required this.subjectName,
      required this.isForClass,
      required this.note,
      this.classSectionName,
      this.teacherName});

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 13.0,
    );
    const valueTextStyle =
        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600);
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      height: 110,
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Row(
          children: [
            SizedBox(
                width: boxConstraints.maxWidth * (0.25),
                child: Column(
                  children: [
                    CustomTextContainer(
                        textKey: (startTime).isEmpty
                            ? "-"
                            : Utils.formatTime(
                                timeOfDay: TimeOfDay(
                                    hour: Utils.getHourFromTimeDetails(
                                        time: startTime),
                                    minute: Utils.getMinuteFromTimeDetails(
                                        time: startTime)),
                                context: context)),
                    const Spacer(),
                    Container(
                      height: 50,
                      width: 1.5,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const Spacer(),
                    CustomTextContainer(
                        textKey: (endTime).isEmpty
                            ? "-"
                            : Utils.formatTime(
                                timeOfDay: TimeOfDay(
                                    hour: Utils.getHourFromTimeDetails(
                                        time: endTime),
                                    minute: Utils.getMinuteFromTimeDetails(
                                        time: endTime)),
                                context: context)),
                  ],
                )),
            SizedBox(
              width: boxConstraints.maxWidth * (0.05),
            ),
            SizedBox(
                width: boxConstraints.maxWidth * (0.7),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding, vertical: 10),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: note.isNotEmpty
                      ? Center(
                          child: CustomTextContainer(
                            textKey: note,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///[Subject name]
                            CustomTextContainer(
                              textKey: subjectKey,
                              style: titleTextStyle,
                            ),
                            CustomTextContainer(
                              textKey: subjectName,
                              style: valueTextStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),

                            ///[Class and teacher name]
                            CustomTextContainer(
                              textKey: isForClass ? teacherKey : classKey,
                              style: titleTextStyle,
                            ),
                            CustomTextContainer(
                              textKey: isForClass
                                  ? (teacherName ?? "-")
                                  : (classSectionName ?? "-"),
                              style: valueTextStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                )),
          ],
        );
      }),
    );
  }
}
