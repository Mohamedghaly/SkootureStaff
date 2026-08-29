import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/readMoreTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItemContainer extends StatelessWidget {
  final NotificationDetails notificationDetails;
  const NotificationItemContainer(
      {super.key, required this.notificationDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          bottom: appContentHorizontalPadding,
          left: appContentHorizontalPadding,
          right: appContentHorizontalPadding),
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((notificationDetails.image ?? "").isNotEmpty) ...[
                _NotificationImagePreview(
                  imageUrl: notificationDetails.image ?? "",
                  heroTag:
                      'notification-image-${notificationDetails.id ?? notificationDetails.image ?? notificationDetails.hashCode}',
                ),
                const SizedBox(
                  width: 15,
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextContainer(
                      textKey: notificationDetails.title ?? "-",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ReadMoreTextContainer(
                      text: notificationDetails.message ?? "-",
                      trimLines: 3,
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextContainer(
            textKey: timeago.format(
                Utils.parseDateSafely(notificationDetails.createdAt!) ??
                    DateTime.now()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12.0, color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}

class _NotificationImagePreview extends StatelessWidget {
  const _NotificationImagePreview(
      {required this.imageUrl, required this.heroTag});

  final String imageUrl;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 80,
      child: GestureDetector(
        onTap: () => Utils.showImagePreview(
            context: context, imageUrl: imageUrl, heroTag: heroTag),
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: imageUrl,
              placeholder: (context, url) => Container(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.2),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
