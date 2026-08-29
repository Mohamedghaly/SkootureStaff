import 'package:eschool_saas_staff/data/models/onlineClass/onlineClass.dart';
import 'package:eschool_saas_staff/ui/screens/onlineClass/widgets/onlineClassStatusPill.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A single online class card shown in the list.
class OnlineClassCard extends StatelessWidget {
  final OnlineClass onlineClass;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OnlineClassCard({
    super.key,
    required this.onlineClass,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, secondary),
            const SizedBox(height: 8),
            // Description (note)
            if (onlineClass.note.isNotEmpty) ...[
              Text(
                onlineClass.note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  color: Color(0xFF6D6E6F),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildDateTimeRow(context, secondary),
            const SizedBox(height: 8),
            _buildRepeatChip(context),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
            _buildLinkRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color secondary) {
    return Row(
      children: [
        Flexible(
          child: Text(
            onlineClass.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 24 / 16,
              color: secondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        OnlineClassStatusPill(status: onlineClass.status),
        const Spacer(),
        if (onEdit != null)
          _ActionIconButton(icon: Icons.edit_outlined, onTap: onEdit!),
        if (onDelete != null) ...[
          const SizedBox(width: 4),
          _ActionIconButton(icon: Icons.delete_outline, onTap: onDelete!),
        ],
      ],
    );
  }

  Widget _buildDateTimeRow(BuildContext context, Color secondary) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 14, color: secondary),
        const SizedBox(width: 4),
        Text(
          onlineClass.startDate != null
              ? DateFormat('d-M-yyyy').format(onlineClass.startDate!)
              : '',
          style: TextStyle(fontSize: 12, height: 16 / 12, color: secondary),
        ),
        const SizedBox(width: 8),
        Container(
          width: 1,
          height: 12,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(width: 8),
        Icon(Icons.access_time, size: 14, color: secondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            onlineClass.timeRange,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, height: 16 / 12, color: secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatChip(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        Utils.getTranslatedLabel(onlineClass.repeat.labelKey),
        style: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildLinkRow(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(Icons.link, size: 20, color: primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            onlineClass.meetingLink,
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

/// Circular icon button used for edit / delete actions on the card.
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
