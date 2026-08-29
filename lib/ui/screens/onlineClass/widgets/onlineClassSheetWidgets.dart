import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Header row for the online class bottom sheets: a title and a close icon,
/// separated from the body by a bottom border.
class OnlineClassSheetHeader extends StatelessWidget {
  final String titleKey;
  final VoidCallback onClose;

  const OnlineClassSheetHeader({
    super.key,
    required this.titleKey,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              Utils.getTranslatedLabel(titleKey),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 24 / 16,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, size: 24),
          ),
        ],
      ),
    );
  }
}

/// A label + value stacked vertically, used to lay out the read-only fields
/// on the summary / detail sheets.
class OnlineClassDetailRow extends StatelessWidget {
  final String labelKey;
  final String value;
  final Widget? trailing;

  const OnlineClassDetailRow({
    super.key,
    required this.labelKey,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Utils.getTranslatedLabel(labelKey),
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  color: Color(0xFF6D6E6F),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small green "No Repeat / Weekly / …" pill shown beside the subject on the
/// detail sheet.
class OnlineClassRepeatPill extends StatelessWidget {
  final String labelKey;

  const OnlineClassRepeatPill({super.key, required this.labelKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF6E3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        Utils.getTranslatedLabel(labelKey),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          color: Color(0xFF2BA24C),
        ),
      ),
    );
  }
}

/// Highlighted info box (light background) holding a schedule sentence.
class OnlineClassInfoBox extends StatelessWidget {
  final String text;

  const OnlineClassInfoBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          height: 18 / 13,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

/// A row showing the meeting link with a leading link icon (underlined,
/// primary colour).
class OnlineClassSheetLinkRow extends StatelessWidget {
  final String link;

  const OnlineClassSheetLinkRow({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(Icons.link, size: 20, color: primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            link,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: primary,
              decoration: TextDecoration.underline,
              decorationColor: primary,
            ),
          ),
        ),
      ],
    );
  }
}
