import 'package:eschool_saas_staff/data/models/chatUser.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class ChatContact {
  const ChatContact({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
    required this.lastMessage,
    required this.hasAttachment,
    required this.user,
    this.lastMessageTime,
  });

  ChatContact.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        senderId = json['sender_id'] as int,
        receiverId = json['receiver_id'] as int,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String,
        unreadCount = json['unread_count'] as int,
        lastMessage = json['last_message'] as String?,
        hasAttachment = json['has_attachment'] as bool? ?? false,
        lastMessageTime = json['last_message_time'] as String?,
        user = ChatUser.fromJson(json['user']);

  final int id;
  final int senderId;
  final int receiverId;
  final String createdAt;
  final String updatedAt;
  final int unreadCount;
  final String? lastMessage;
  final bool hasAttachment;
  final ChatUser user;

  /// Server-formatted time string for the last message, e.g. "06-03-2026 09:16".
  /// Preferred over [updatedAt] for display as it is pre-formatted by the backend.
  final String? lastMessageTime;

  /// Get display message - returns attachment label if no message but has attachment
  String get displayMessage {
    if ((lastMessage == null || lastMessage!.isEmpty) && hasAttachment) {
      return Utils.getTranslatedLabel(attachmentKey);
    }
    return lastMessage ?? '';
  }

  ChatContact copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? createdAt,
    String? updatedAt,
    int? unreadCount,
    String? lastMessage,
    bool? hasAttachment,
    ChatUser? user,
    String? lastMessageTime,
  }) {
    return ChatContact(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      user: user ?? this.user,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
}
