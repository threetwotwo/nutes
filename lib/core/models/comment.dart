import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutes/core/models/user.dart';

class Comment {
  final String id;
  final User owner;

  ///The comment is a reply to another comment if [parentId] is null
  final String parentId;

  ///owner of the parent comment
  final User parentOwner;
  final Timestamp timestamp;
  final CommentStats stats;
  final String text;

  final DocumentSnapshot doc;

  Comment({
    this.id,
//    @required this.post,
    this.parentId,
    this.parentOwner,
    @required this.text,
    @required this.timestamp,
    @required this.owner,
    this.stats,
    this.doc,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    final likeCount = doc['like_count'] ?? 0;
    final replyCount = doc['reply_count'] ?? 0;

    return Comment(
      id: doc.documentID,
//      post: post,
      timestamp: doc['timestamp'],
      owner: User.fromMap(doc['owner'] ?? {}),
      parentId: doc['parent_id'] ?? '',
      parentOwner: User.fromMap(doc['parent_owner'] ?? {}),
      text: doc['text'] ?? '',
      stats: CommentStats(replyCount: replyCount, likeCount: likeCount),
      doc: doc,
    );
  }

  Comment copyWith({int likeCount, int replyCount}) {
    return Comment(
        id: id,
        timestamp: timestamp,
        owner: owner,
        parentId: parentId,
        parentOwner: parentOwner,
        text: text,
        doc: doc,
        stats: CommentStats(
            likeCount: likeCount ?? stats.likeCount,
            replyCount: replyCount ?? stats.replyCount));
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp,
        'parent_id': parentId ?? 'root',
        if (parentOwner != null) 'parent_owner': parentOwner.toMap(),
        'text': text,
        'owner': owner.toMap(),
      };
}

class CommentStats {
  final int likeCount;
  final int replyCount;

  CommentStats({this.likeCount, this.replyCount});
}

///For pagination
class CommentCursor {
  final List<Comment> comments;
  final DocumentSnapshot startAfter;
//  final DocumentSnapshot endAt;

  CommentCursor(
    this.comments,
    this.startAfter,
//    this.endAt,
  );
}
