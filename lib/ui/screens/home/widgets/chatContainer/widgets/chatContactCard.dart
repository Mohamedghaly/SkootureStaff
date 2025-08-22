import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/data/models/chatContact.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class ChatContactCard extends StatelessWidget {
  const ChatContactCard({super.key, required this.contact, this.onTap});

  final ChatContact contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            border: const Border(
              top: BorderSide.none,
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide(color: Color(0xFFEBEEF3)),
            ),
          ),
          child: Row(
            children: [
              /// User profile image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.tertiary,
                ),
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: contact.user.image,
                    fit: BoxFit.cover,
                    width: 48,
                    height: 48,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              ///
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// User name and last message time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.user.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            Utils.extractTimeFromDateString(contact.updatedAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1.5),

                      /// Last message and unread count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.lastMessage ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),

                          ///
                          if (contact.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .extension<CustomColors>()!
                                    .redColor!,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                contact.unreadCount.toString(),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
