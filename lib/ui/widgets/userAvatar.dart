import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  String _getInitials(String name) {
    List<String> words = name.trim().split(' ');
    if (words.isEmpty) return 'U';

    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : 'U';
    } else {
      String initials = '';
      if (words[0].isNotEmpty) initials += words[0][0].toUpperCase();
      if (words[1].isNotEmpty) initials += words[1][0].toUpperCase();
      return initials;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    // Generate color based on name for consistency
    int nameHash = name.hashCode;
    List<Color> colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
      Colors.red.shade400,
    ];

    return colors[nameHash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _getBackgroundColor(context),
      backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
          ? NetworkImage(imageUrl!)
          : null,
      onBackgroundImageError: (imageUrl != null && imageUrl!.isNotEmpty)
          ? (exception, stackTrace) {
              // Handle image loading error silently
              debugPrint('Failed to load image: $imageUrl');
            }
          : null,
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? Text(
              _getInitials(name),
              style: TextStyle(
                color: iconColor ?? Colors.white,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}

// Extension for enhanced avatar with attendance status
class UserAvatarWithStatus extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String role;
  final double radius;
  final Color? statusColor;
  final String? statusText;

  const UserAvatarWithStatus({
    super.key,
    this.imageUrl,
    required this.name,
    required this.role,
    this.radius = 20,
    this.statusColor,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UserAvatar(
          imageUrl: imageUrl,
          name: name,
          radius: radius,
        ),

        // Status indicator
        if (statusColor != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: statusText != null
                  ? Center(
                      child: Text(
                        statusText!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: radius * 0.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
