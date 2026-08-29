import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Circular staff avatar with a white border ring.
/// Shows profile image from [imageUrl]; falls back to a person icon
/// on null, empty URL, or load error.
///
/// Used in:
///   - Task card assignee footer
///   - Add/Edit task selected-staff list
class CircularStaffAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const CircularStaffAvatar({
    super.key,
    this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _fallback();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) => _fallback(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFE3E7FE),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: const Color(0xFF6D6E6F),
      ),
    );
  }
}
