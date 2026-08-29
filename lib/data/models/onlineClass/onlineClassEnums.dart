import 'package:eschool_saas_staff/utils/labelKeys.dart';

/// Lifecycle status of an [OnlineClass].
///
/// This is currently derived from dummy data. Once the backend is wired,
/// the value should come straight from the API `status` field so that the
/// server stays the single source of truth (see backend notes).
///
/// * [live]     – the class is happening right now.
/// * [upcoming] – the class is scheduled for a future date/time.
/// * [past]     – the class already finished.
enum OnlineClassStatus {
  live,
  upcoming,
  past;

  /// Translation key used to render the status label.
  String get labelKey {
    switch (this) {
      case OnlineClassStatus.live:
        return liveKey;
      case OnlineClassStatus.upcoming:
        return upcomingKey;
      case OnlineClassStatus.past:
        return pastKey;
    }
  }

  /// Value sent to / received from the backend.
  String get apiValue {
    switch (this) {
      case OnlineClassStatus.live:
        return 'live';
      case OnlineClassStatus.upcoming:
        return 'upcoming';
      case OnlineClassStatus.past:
        return 'past';
    }
  }

  /// Resolves a status from its backend string. Defaults to [upcoming].
  static OnlineClassStatus fromString(String? value) {
    switch (value) {
      case 'live':
        return OnlineClassStatus.live;
      case 'past':
        return OnlineClassStatus.past;
      case 'upcoming':
      default:
        return OnlineClassStatus.upcoming;
    }
  }
}

/// Recurrence pattern selected while creating / editing an online class.
///
/// * [noRepeat]   – a single class on one specific date & period.
/// * [everyClass] – a class is created for every matching slot of the
///                  selected subject's timetable up to the end date.
/// * [weekly]     – the selected class repeats every week until the end date.
enum OnlineClassRepeatType {
  noRepeat,
  everyClass,
  weekly;

  /// Translation key used to render the repeat label.
  String get labelKey {
    switch (this) {
      case OnlineClassRepeatType.noRepeat:
        return noRepeatKey;
      case OnlineClassRepeatType.everyClass:
        return everyClassKey;
      case OnlineClassRepeatType.weekly:
        return weeklyKey;
    }
  }

  /// Translation key for the helper line shown beneath the repeat selector.
  String get helperKey {
    switch (this) {
      case OnlineClassRepeatType.noRepeat:
        return noRepeatHelperKey;
      case OnlineClassRepeatType.everyClass:
        return everyClassHelperKey;
      case OnlineClassRepeatType.weekly:
        return weeklyHelperKey;
    }
  }

  /// Value sent to / received from the backend.
  ///
  /// These strings match the Laravel `Timetable::REPEAT_TYPES` constants
  /// exactly — they are stored verbatim in the `timetables.repeat` column.
  String get apiValue {
    switch (this) {
      case OnlineClassRepeatType.noRepeat:
        return 'No Repeat';
      case OnlineClassRepeatType.everyClass:
        return 'Every Class Period';
      case OnlineClassRepeatType.weekly:
        return 'Weekly';
    }
  }

  /// Recurring patterns ([everyClass], [weekly]) require an end date.
  bool get requiresEndDate => this != OnlineClassRepeatType.noRepeat;

  /// "Every Class Period" applies to every slot of the subject, so individual
  /// period selection is not required for it.
  bool get requiresPeriodSelection => this != OnlineClassRepeatType.everyClass;

  /// Resolves a repeat type from its backend string. Defaults to [noRepeat].
  static OnlineClassRepeatType fromString(String? value) {
    switch (value) {
      case 'Every Class Period':
        return OnlineClassRepeatType.everyClass;
      case 'Weekly':
        return OnlineClassRepeatType.weekly;
      case 'No Repeat':
      default:
        return OnlineClassRepeatType.noRepeat;
    }
  }
}
