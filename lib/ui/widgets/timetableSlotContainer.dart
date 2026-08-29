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

  /// Whether this slot is configured as an online class (shows the
  /// "Online Class" label, and a "Live" badge when [isLive]).
  final bool isOnlineClass;
  final bool isLive;

  const TimetableSlotContainer(
      {super.key,
      required this.startTime,
      required this.endTime,
      required this.subjectName,
      required this.isForClass,
      required this.note,
      this.classSectionName,
      this.teacherName,
      this.isOnlineClass = false,
      this.isLive = false});

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
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return IntrinsicHeight(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  child: _buildContent(
                      context, titleTextStyle, valueTextStyle),
                )),
          ],
        ));
      }),
    );
  }

  Widget _buildContent(
      BuildContext context, TextStyle titleTextStyle, TextStyle valueTextStyle) {
    // Online class slots always show subject/class with the labels on top,
    // never the centered "note" layout used for breaks.
    if (isOnlineClass) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelsRow(context),
          const SizedBox(height: 16),
          ..._subjectAndClass(titleTextStyle, valueTextStyle),
        ],
      );
    }

    if (note.isNotEmpty) {
      return Center(
        child: CustomTextContainer(
          textKey: note,
          style: const TextStyle(fontSize: 18.0),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _subjectAndClass(titleTextStyle, valueTextStyle),
    );
  }

  /// The "Online Class" label on the left and an optional "Live" badge on the
  /// right.
  Widget _buildLabelsRow(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F5EC),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            Utils.getTranslatedLabel(onlineClassKey),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
              color: Color(0xFF57CC99),
            ),
          ),
        ),
        const Spacer(),
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF9D2D2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBB1B1B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  Utils.getTranslatedLabel(liveKey),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    letterSpacing: 0.5,
                    color: Color(0xFFBB1B1B),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _subjectAndClass(
      TextStyle titleTextStyle, TextStyle valueTextStyle) {
    return [
      ///[Subject name]
      CustomTextContainer(textKey: subjectKey, style: titleTextStyle),
      CustomTextContainer(
        textKey: subjectName,
        style: valueTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 10),

      ///[Class and teacher name]
      CustomTextContainer(
        textKey: isForClass ? teacherKey : classKey,
        style: titleTextStyle,
      ),
      CustomTextContainer(
        textKey: isForClass ? (teacherName ?? "-") : (classSectionName ?? "-"),
        style: valueTextStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }
}
