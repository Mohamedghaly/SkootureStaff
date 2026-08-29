import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:intl/intl.dart';

/// Shared helpers for the Online Class feature.
///
/// The list / periods are read from the existing `teacher/teacher_timetable`
/// API, which returns 24h times (`HH:mm:ss`) and `Y-m-d` dates and does NOT
/// pre-compute a live/upcoming/past status. These helpers normalise those
/// values and derive the status on the client.
class OnlineClassUtils {
  const OnlineClassUtils._();

  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Formats an API time (`08:26:00` / `08:26`) to display form (`8:26 AM`).
  /// Already-formatted values (containing AM/PM) are returned untouched.
  static String formatTime(String raw) {
    if (raw.isEmpty) return raw;
    final upper = raw.toUpperCase();
    if (upper.contains('AM') || upper.contains('PM')) return raw;
    final parts = _parseTimeParts(raw);
    if (parts == null) return raw;
    final dt = DateTime(2000, 1, 1, parts.$1, parts.$2, parts.$3);
    return DateFormat('h:mm a').format(dt);
  }

  /// Parses a `Y-m-d` (optionally with time) date string.
  static DateTime? parseDate(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  /// Derives the live/upcoming/past status from the schedule, mirroring the
  /// server-side logic in `OnlineClassController` of the admin panel.
  ///
  /// * past:     the whole schedule has ended.
  /// * live:     today is in range, the weekday matches and the current time
  ///             is within the period window.
  /// * upcoming: anything else.
  static OnlineClassStatus deriveStatus({
    required DateTime? startDate,
    required DateTime? endDate,
    required OnlineClassRepeatType repeat,
    required String day,
    required String startTimeRaw,
    required String endTimeRaw,
  }) {
    if (startDate == null) return OnlineClassStatus.upcoming;

    final start = _parseTimeParts(startTimeRaw) ?? (0, 0, 0);
    final end = _parseTimeParts(endTimeRaw) ?? (23, 59, 59);
    final now = DateTime.now();

    final bool recurring = repeat != OnlineClassRepeatType.noRepeat;
    final DateTime lastDay =
        (recurring && endDate != null) ? endDate : startDate;

    final endBoundary = DateTime(
      lastDay.year,
      lastDay.month,
      lastDay.day,
      end.$1,
      end.$2,
      end.$3,
    );
    if (now.isAfter(endBoundary)) return OnlineClassStatus.past;

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
    final rangeEnd =
        DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59);
    final inRange = !now.isBefore(rangeStart) && !now.isAfter(rangeEnd);

    final weekdayMatches = recurring
        ? _weekdayName(now.weekday) == day
        : (now.year == startDate.year &&
            now.month == startDate.month &&
            now.day == startDate.day);

    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;
    final startSec = start.$1 * 3600 + start.$2 * 60 + start.$3;
    final endSec = end.$1 * 3600 + end.$2 * 60 + end.$3;
    final withinTime = nowSec >= startSec && nowSec <= endSec;

    if (inRange && weekdayMatches && withinTime) {
      return OnlineClassStatus.live;
    }
    return OnlineClassStatus.upcoming;
  }

  static String _weekdayName(int weekday) =>
      _weekdayNames[(weekday - 1).clamp(0, 6)];

  /// Parses `HH:mm[:ss]` (24h) or `h:mm[:ss] a` into (hour, minute, second).
  static (int, int, int)? _parseTimeParts(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final upper = value.toUpperCase();
    final isPm = upper.contains('PM');
    final isAm = upper.contains('AM');
    final cleaned = upper.replaceAll('AM', '').replaceAll('PM', '').trim();

    final segments = cleaned.split(':');
    if (segments.isEmpty) return null;

    var hour = int.tryParse(segments[0]) ?? 0;
    final minute = segments.length > 1 ? int.tryParse(segments[1]) ?? 0 : 0;
    final second = segments.length > 2 ? int.tryParse(segments[2]) ?? 0 : 0;

    if (isAm || isPm) {
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
    }
    return (hour, minute, second);
  }
}
