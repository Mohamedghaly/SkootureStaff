import 'package:eschool_saas_staff/data/models/onlineClass/onlineClassEnums.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Small rounded status badge with a leading dot, e.g. `● Live`.
///
/// * live     – error-light background, error foreground.
/// * upcoming – light blue background, blue foreground.
/// * past     – light grey background, grey foreground.
class OnlineClassStatusPill extends StatelessWidget {
  final OnlineClassStatus status;

  const OnlineClassStatusPill({super.key, required this.status});

  static const _live = (bg: Color(0xFFF9D2D2), fg: Color(0xFFBB1B1B));
  static const _upcoming = (bg: Color(0xFFE0EEFF), fg: Color(0xFF006DF5));
  static const _past = (bg: Color(0xFFF0F0F0), fg: Color(0xFF6D6E6F));

  ({Color bg, Color fg}) get _colors {
    switch (status) {
      case OnlineClassStatus.live:
        return _live;
      case OnlineClassStatus.upcoming:
        return _upcoming;
      case OnlineClassStatus.past:
        return _past;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors.fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            Utils.getTranslatedLabel(status.labelKey),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              letterSpacing: 0.5,
              color: colors.fg,
            ),
          ),
        ],
      ),
    );
  }
}
