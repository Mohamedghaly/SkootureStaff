import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/data/models/staffMember.dart';
import 'package:flutter/material.dart';

/// Staff card with avatar, name, role, and checkbox.

class StaffCard extends StatelessWidget {
  final StaffMember staff;
  final bool isSelected;
  final VoidCallback onTap;

  const StaffCard({
    super.key,
    required this.staff,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Avatar — real image or fallback icon
            StaffAvatar(imageUrl: staff.imageUrl),
            const SizedBox(width: 16),

            // Name & Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    staff.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            _CustomCheckbox(isChecked: isSelected),
          ],
        ),
      ),
    );
  }
}

/// Displays the staff member's profile image with a
/// rounded container. Falls back to a person icon when
/// no image URL is available or loading fails.
class StaffAvatar extends StatelessWidget {
  final String? imageUrl;

  const StaffAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xA3EBEEF3),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _fallbackIcon();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      width: 42,
      height: 42,
      placeholder: (_, __) => _fallbackIcon(),
      errorWidget: (_, __, ___) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: const Color(0xFFE0EDF6),
      child: const Icon(
        Icons.person,
        size: 24,
        color: Color(0xFF6D6E6F),
      ),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  final bool isChecked;

  const _CustomCheckbox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isChecked
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            border: isChecked
                ? null
                : Border.all(
                    color: const Color(0xFF1A1C1D),
                    width: 2,
                  ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: isChecked
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
