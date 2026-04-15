import 'package:eschool_saas_staff/utils/utils.dart';

class PublicHoliday {
  final DateTime? date;
  final String? title;

  PublicHoliday({
    this.date,
    this.title,
  });

  PublicHoliday.fromJson(Map<String, dynamic> json)
      : date = json['dmyFormat'] != null
            ? Utils.parseDateSafely(json['dmyFormat'].toString())
            : null,
        title = json['title'] as String?;

  Map<String, dynamic> toJson() => {
        'dmyFormat': date != null ? Utils.getFormattedDate(date!) : null,
        'title': title,
      };
}
