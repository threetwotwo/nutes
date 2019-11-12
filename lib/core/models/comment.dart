import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutes/core/models/user.dart';

class Comment {
  final String id;
  final User uploader;
  final String postId;
  final String parentId;
  final Timestamp timestamp;
  final CommentStats stats;
  final String text;

  Comment({
    this.id,
    @required this.postId,
    @required this.text,
    this.parentId,
    @required this.timestamp,
    @required this.uploader,
    this.stats,
  });
}

class CommentStats {
  final int likeCount;
  final int replyCount;

  CommentStats({this.likeCount, this.replyCount});
}
