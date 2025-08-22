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
                Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: notificationDetails.image ?? "",
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/splash_logo.png'),
                    )),
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
            textKey:
                timeago.format(Utils.parseDateSafely(notificationDetails.createdAt!) ?? DateTime.now()),
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
