import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImageContainer extends StatelessWidget {
  final String imageUrl;
  final double? heightAndWidth;
  const ProfileImageContainer(
      {super.key, this.heightAndWidth, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: heightAndWidth ?? 70,
      height: heightAndWidth ?? 70,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5.0)),
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.5),
            image: imageUrl.isEmpty
                ? null
                : DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(imageUrl))),
        child: imageUrl.isEmpty
            ? const Center(
                child: Icon(
                  Icons.person,
                  size: 25,
                ),
              )
            : null,
      ),
    );
  }
}
//"https://www.hollywoodreporter.com/wp-content/uploads/2024/02/sq110_s300_f206_2K_final-H-2024.jpg?w=1296"