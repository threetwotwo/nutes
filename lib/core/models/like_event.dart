import 'package:flutter/foundation.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';

class LikeEvent {
//  final String id;
  final String likerId;
  final String postId;
  final String postOwnerId;
  final User liker;
  final User postOwner;
  final Post post;
  final bool isFollowingPostOwner;

  LikeEvent({
    @required this.likerId,
    @required this.postId,
    @required this.postOwnerId,
    this.liker,
    this.postOwner,
    this.post,
    this.isFollowingPostOwner,
  });
}
