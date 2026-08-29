import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:intl/intl.dart';

/// Builds the human-readable schedule sentences shown inside the highlighted
/// info boxes on the detail / summary sheets and under the start-date field.
///
/// All copy comes from translatable keys with `{placeholder}` tokens so the
/// strings stay localizable. Tokens are substituted here.
class OnlineClassScheduleNote {
  const OnlineClassScheduleNote._();

  static final DateFormat _long = DateFormat('d MMMM yyyy'); // 22 June 2026
  static final DateFormat _medium = DateFormat('dd MMM yyyy'); // 20 Feb 2026
  static final DateFormat _weekday = DateFormat('EEEE'); // Monday

  /// Note shown beneath the start-date field for the weekly repeat option,
  /// e.g. "This online class will be scheduled on each Monday until the end date."
  static String weeklyFieldNote(DateTime startDate) {
    return Utils.getTranslatedLabel(weeklyScheduleNoteKey)
        .replaceAll('{day}', _weekday.format(startDate));
  }

  /// The info-box sentence for the detail / summary sheets, varying by
  /// [repeatType].
  ///
  /// [periodDay] is the period's weekday (e.g. `Monday`) — used by the
  /// "No Repeat" sentence, since that type carries no dates and is scheduled
  /// on the period's own slot. [long] uses the verbose date format (used on
  /// the create summary sheet); otherwise the medium format is used (detail
  /// sheet).
  static String build({
    required OnlineClassRepeatType repeatType,
    required DateTime date,
    DateTime? endDate,
    required String startTime,
    required String endTime,
    required String subjectName,
    String periodDay = '',
    bool long = false,
  }) {
    final fmt = long ? _long : _medium;
    final dateStr = fmt.format(date);
    final endStr = endDate != null ? fmt.format(endDate) : '';
    final day = _weekday.format(date);

    switch (repeatType) {
      case OnlineClassRepeatType.noRepeat:
        return Utils.getTranslatedLabel(summaryNoRepeatNoteKey)
            .replaceAll('{day}', periodDay.isNotEmpty ? periodDay : day)
            .replaceAll('{start}', startTime)
            .replaceAll('{end}', endTime);
      case OnlineClassRepeatType.weekly:
        return Utils.getTranslatedLabel(summaryWeeklyNoteKey)
            .replaceAll('{day}', day)
            .replaceAll('{start}', startTime)
            .replaceAll('{end}', endTime)
            .replaceAll('{endDate}', endStr);
      case OnlineClassRepeatType.everyClass:
        return Utils.getTranslatedLabel(summaryEveryClassNoteKey)
            .replaceAll('{subject}', subjectName)
            .replaceAll('{startDate}', dateStr)
            .replaceAll('{endDate}', endStr);
    }
  }
}
