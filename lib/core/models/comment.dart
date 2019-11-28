import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';

class Comment {
  final String id;
  final User owner;
//  final Post post;

  ///The comment is a reply to another comment if [parentId] is null
  final String parentId;

  ///owner of the parent comment
  final User parentOwner;
  final Timestamp timestamp;
  final CommentStats stats;
  final String text;

  Comment({
    this.id,
//    @required this.post,
    this.parentId,
    this.parentOwner,
    @required this.text,
    @required this.timestamp,
    @required this.owner,
    this.stats,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data;

    final post = null;

    return Comment(
      id: doc.documentID,
//      post: post,
      timestamp: data['published'] ?? '',
      owner: User.fromMap(data['owner'] ?? {}),
      parentId: data['parent_id'] ?? '',
      parentOwner: User.fromMap(data['parent_owner'] ?? {}),
      text: data['text'] ?? '',
    );
  }
}

class CommentStats {
  final int likeCount;
  final int replyCount;

  CommentStats({this.likeCount, this.replyCount});
}
