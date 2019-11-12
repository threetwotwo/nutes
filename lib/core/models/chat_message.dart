import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

///temp signifies that it is a placeholder
enum Bubbles {
  text,
  text_temp,

  photo,
  photo_temp,

  shout_challenge,
  shout_challenge_temp,

  shout_complete,
  shout_complete_temp,

  isTyping,
  loadMore,
}

class BubbleHelper {
  static Bubbles getBubbleFromString(String val) {
    val = 'Bubbles.$val';
    return Bubbles.values
        .firstWhere((b) => b.toString() == val, orElse: () => null);
  }

  static String stringValue(Bubbles bubble) {
    return bubble.toString().split('.')[1];
  }
}

enum Placeholders { text, photo, shout_challenge, shout_complete }

class PlaceholderHelper {
  static Placeholders getPlaceholderFromString(String val) {
    val = 'Placeholders.$val';
    return Placeholders.values
        .firstWhere((b) => b.toString() == val, orElse: () => null);
  }

  static String stringValue(Placeholders placeholder) {
    return placeholder.toString().split('.')[1];
  }
}

/// A [ChatItem] object
///  to populate a [ChatScreen]
class ChatItem {
  ///Unique identifier
  final String id;

  ///Sender id
  final String senderId;

  final Bubbles type;

  ///Content of message;
  final String content;

  ///Date created
  final Timestamp timestamp;

  final Map metadata;

  ChatItem({
    @required this.type,
    this.id,
    this.senderId,
    this.content,
    this.timestamp,
    this.metadata,
  });

  static ChatItem fromDoc(DocumentSnapshot doc) {
    return ChatItem(
      id: doc.documentID,
      senderId: doc['sender_id'] ?? '',
      type: BubbleHelper.getBubbleFromString(doc['type'].toString() ?? ''),
      content: doc['content'] ?? '',
      timestamp: doc['timestamp'],
      metadata: doc['metadata'] ?? {},
    );
  }
}
