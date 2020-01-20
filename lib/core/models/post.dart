import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/utils/image_file_bundle.dart';

class PostContent {
  final List<ImageUrlBundle> urls;
  final Map metadata;

  PostContent({this.urls, this.metadata});

  factory PostContent.fromDoc(DocumentSnapshot doc) {
    final List<Map> urlBundle = doc['urls'] ?? [];
    final Map metadata = doc['metadata'];

    if (urlBundle.isEmpty && metadata == null) return null;
    final urls = urlBundle
        .map((e) => ImageUrlBundle.fromMap(urlBundle.indexOf(e), e))
        .toList();

    return PostContent(urls: urls, metadata: metadata);
  }
}

///For pagination
class PostCursor {
  final List<Post> posts;
  final DocumentSnapshot startAfter;
  final DocumentSnapshot endAt;

  PostCursor(this.posts, this.startAfter, this.endAt);
}

class Post {
  final String id;
  final User owner;
  final List<ImageUrlBundle> urlBundles;
  final Timestamp timestamp;
//  final bool didLike;
//  final bool challengerDidLike;
//  final bool challengedDidLike;
//  final PostMyLikes myLikes;
  PostStats stats;
  final Map metadata;
  final String caption;
  final List<Comment> topComments;

  ///List of users who are also my followings who liked this post
  final List<User> myFollowingLikes;
  final PostType type;

  double get biggestAspectRatio {
    final ars = urlBundles.map((b) => b.aspectRatio).toList();
    return ars.reduce(min);
  }

  Post({
    @required this.type,
    @required this.id,
    @required this.owner,
    @required this.timestamp,
    @required this.urlBundles,
//    @required this.didLike,
//    this.myLikes,
//    this.challengerDidLike,
//    this.challengedDidLike,
    this.stats,
    this.metadata,
    this.caption,
    this.topComments,
    this.myFollowingLikes = const [],
  });

  Post copyWith({
//    bool didLike,
//    bool challengerDidLike,
//    bool challengedDidLike,
//    PostMyLikes myLikes,
    PostStats stats,
    List<User> myFollowingLikes,
    String caption,
    User uploader,
    List<Comment> topComments,
  }) {
    return Post(
      type: this.type,
      id: this.id,
      owner: this.owner,
      urlBundles: this.urlBundles,
      timestamp: this.timestamp,

      stats: stats ?? this.stats,
      metadata: this.metadata,
      caption: caption ?? this.caption,
      topComments: topComments ?? this.topComments,
      myFollowingLikes: myFollowingLikes ?? this.myFollowingLikes ?? [],
//      myLikes: myLikes ?? this.myLikes,
      //      didLike: didLike ?? this.didLike,
//      challengerDidLike: challengerDidLike ?? this.challengerDidLike ?? false,
//      challengedDidLike: challengedDidLike ?? this.challengedDidLike ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    final bundleMaps = urlBundles
            .map((b) => {
                  'original': b.original,
                  'medium': b.medium,
                  'small': b.small,
                  'aspect_ratio': b.aspectRatio ?? 1,
                })
            .toList() ??
        {};
    return {
      'type': PostHelper.stringValue(type),
      'post_id': id,
      'urls': bundleMaps,
      'metadata': metadata,
      'owner': owner.toMap(),
      'caption': caption,
//      'published': timestamp,
    };
  }

  factory Post.fromMap(Map map) {
    final List urlBundle = map['urls'] ?? [];

    if (urlBundle.isEmpty && map['data'] == null && map['metadata'] == null) {
      print('post has no data');
      return null;
    }
    final urlBundles = urlBundle
        .map((e) => ImageUrlBundle.fromMap(urlBundle.indexOf(e), e))
        .toList();

    final uploader = User.fromMap(map['uploader'] ?? {});

    final caption = map['caption'] ?? '';

    PostType type;

    final docType = map['type'];

    if (docType is int) {
      type = docType == 0 ? PostType.text : PostType.shout;
    } else
      type = PostHelper.postType(map['type'].toString());

    if (type == null) {
      print('post has no type');
      return null;
    }

    final post = Post(
      id: map['post_id'],
      type: type,
      owner: uploader,
      urlBundles: urlBundles,
      timestamp: map['timestamp'] ?? Timestamp.now(),
      metadata: map['metadata'] ?? {},
      caption: caption,
    );
    return post.id == null ? null : post;
  }
  factory Post.fromDoc(DocumentSnapshot doc) {
    if (doc == null || doc.data == null) return null;

    final List urlBundle = doc['urls'] ?? [];

    if (urlBundle.isEmpty && doc['data'] == null) return null;

    final urlBundles = urlBundle
        .map((e) => ImageUrlBundle.fromMap(urlBundle.indexOf(e), e))
        .toList();

    final uploader = User.fromMap(doc['uploader'] ?? {});

    final caption = doc['caption'] ?? '';

    PostType type;

    final docType = doc['type'];

    if (docType is int) {
      type = docType == 0 ? PostType.text : PostType.shout;
    } else
      type = PostHelper.postType(doc['type'].toString());

    if (type == null) return null;

    final post = Post(
      id: doc.documentID,
      type: type,
      owner: uploader,
      urlBundles: urlBundles,
      timestamp: doc['timestamp'] ?? Timestamp.now(),
      metadata: doc['data'] ?? {},
      caption: caption,
    );
    return post;
  }
}

class PostStats {
  final String postId;
  final int likeCount;
  final int commentCount;

  ///for shouts
  final int shoutLeftLikeCount;
  final int shoutRightLikeCount;

  ///uid of post owner
  final String ownerId;
//  final List<Comment> topComments;

  PostStats({
    this.ownerId,
    @required this.postId,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shoutLeftLikeCount = 0,
    this.shoutRightLikeCount = 0,
//    this.topComments,
  });

  PostStats copyWith({
    int likeCount,
    int commentCount,
    int shoutLeftLikeCount,
    int shoutRightLikeCount,
    List<Comment> comments,
  }) {
    return PostStats(
      postId: this.postId,
      ownerId: this.ownerId,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shoutLeftLikeCount: shoutLeftLikeCount ?? this.shoutLeftLikeCount,
      shoutRightLikeCount: shoutRightLikeCount ?? this.shoutRightLikeCount,
//      topComments: comments ?? this.topComments,
    );
  }

  factory PostStats.fromDoc(DocumentSnapshot doc) {
    final data = doc.data;
    final List comments = (data['top_comments'] ?? []);
    return PostStats(
      ownerId: data['owner_id'],
      postId: doc.documentID,
      likeCount: data['like_count'] ?? 0,
      commentCount: data['comment_count'] ?? 0,
      shoutLeftLikeCount: data['shout_left_like_count'] ?? 0,
      shoutRightLikeCount: data['shout_right_like_count'] ?? 0,
//      topComments: comments.map((c) => Comment.fromDoc(doc));
    );
  }

  factory PostStats.empty(String postId) {
    return PostStats(
      postId: postId,
      likeCount: 0,
      commentCount: 0,
      shoutLeftLikeCount: 0,
      shoutRightLikeCount: 0,
    );
  }

//  factory PostStats.fromSnap(DataSnapshot snap) {
//    final data = snap.value;
//
//    if (snap.value == null) {
//      return PostStats(likeCount: 0, commentCount: 0);
//    }
//
//    return PostStats(
//      likeCount: data['like_count'] ?? 0,
//      commentCount: data['comment_count'] ?? 0,
//      challengerCount: data['challenger_like_count'] ?? 0,
//      challengedCount: data['challenged_like_count'] ?? 0,
//    );
//  }
}
