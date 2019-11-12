import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
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

///Idea on how to have a 'harmonized' post object built from data
///strewn all over firestore
class PostV2 {
  final String id;
  final User owner;
  final PostContent content;
  final PostStats stats;

  PostV2({this.id, this.owner, this.content, this.stats});
}

class PostMyLikes {
  final bool didLike;
  final bool challengerDidLike;
  final bool challengedDidLike;

  PostMyLikes({
    @required this.didLike,
    @required this.challengerDidLike,
    @required this.challengedDidLike,
  });

  factory PostMyLikes.fromList(List list) {
    return PostMyLikes(
      didLike: list.contains('post') ?? false,
      challengerDidLike: list.contains('left_like') ?? false,
      challengedDidLike: list.contains('right_like') ?? false,
    );
  }
}

class PostCursor {
  final List<Post> posts;
  final DocumentSnapshot startAfter;

  PostCursor(this.posts, this.startAfter);
}

class Post {
  final String id;
  final User owner;
  final List<ImageUrlBundle> urls;
  final Timestamp timestamp;
  final bool didLike;
  final bool challengerDidLike;
  final bool challengedDidLike;
  final PostMyLikes myLikes;
  PostStats stats;
  final Map metadata;

  ///List of users who are also my followings who liked this post
  final List<User> myFollowingLikes;
  final PostType type;

  Post({
    @required this.type,
    @required this.id,
    @required this.owner,
    @required this.timestamp,
    @required this.urls,
    @required this.didLike,
    this.myLikes,
    this.challengerDidLike,
    this.challengedDidLike,
    this.stats,
    this.metadata,
    this.myFollowingLikes = const [],
  });

  Post copyWith({
    bool didLike,
    bool challengerDidLike,
    bool challengedDidLike,
    PostStats stats,
    PostMyLikes myLikes,
    List<User> myFollowingLikes,
    User uploader,
  }) {
    return Post(
      type: this.type,
      id: this.id,
      owner: this.owner,
      urls: this.urls,
      timestamp: this.timestamp,
      didLike: didLike ?? this.didLike,
      challengerDidLike: challengerDidLike ?? this.challengerDidLike ?? false,
      challengedDidLike: challengedDidLike ?? this.challengedDidLike ?? false,
      stats: stats ?? this.stats,
      metadata: this.metadata,
      myLikes: myLikes ?? this.myLikes,
      myFollowingLikes: myFollowingLikes ?? this.myFollowingLikes ?? [],
    );
  }

  factory Post.fromDoc(DocumentSnapshot doc) {
    final List urlBundle = doc['urls'] ?? [];
    if (urlBundle.isEmpty && doc['data'] == null) return null;
    final urls = urlBundle
        .map((e) => ImageUrlBundle.fromMap(urlBundle.indexOf(e), e))
        .toList();
    final uploaderData = doc['uploader'] ?? {};
    final uploader = User.fromMap(uploaderData);

    PostType type;

    final docType = doc['type'];

    if (docType is int) {
      type = docType == 0 ? PostType.text : PostType.shout;
    } else
      type = PostHelper.postType(doc['type'].toString());

    if (type == null) return null;

//    final stats = PostStats.fromDoc(doc);

    final post = Post(
      id: doc.documentID,
      type: type,
      owner: uploader,
      urls: urls,
      timestamp: doc['timestamp'] ?? Timestamp.now(),
      metadata: doc['data'] ?? {},
      didLike: false,
//      stats: stats,
    );
    return post;
  }
}

class PostStats {
  final String postId;
  final int likeCount;
  final int commentCount;

  ///for shouts
  final int challengerCount;
  final int challengedCount;

  ///uid of post owner
  final String ownerId;

  PostStats({
    this.ownerId,
    @required this.postId,
    this.likeCount = 0,
    this.commentCount = 0,
    this.challengerCount = 0,
    this.challengedCount = 0,
  });

  PostStats copyWith({
    int likeCount,
    int commentCount,
    int challengerCount,
    int challengedCount,
  }) {
    return PostStats(
      postId: this.postId,
      ownerId: this.ownerId,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      challengerCount: challengerCount ?? this.challengerCount,
      challengedCount: challengedCount ?? this.challengedCount,
    );
  }

  factory PostStats.fromDoc(DocumentSnapshot doc) {
    final data = doc.data;
    return PostStats(
      ownerId: data['owner_id'],
      postId: doc.documentID,
      likeCount: data['like_count'] ?? 0,
      commentCount: data['comment_count'] ?? 0,
      challengerCount: data['left_like_count'] ?? 0,
      challengedCount: data['right_like_count'] ?? 0,
    );
  }

  factory PostStats.empty(String postId) {
    return PostStats(
      postId: postId,
      likeCount: 0,
      commentCount: 0,
      challengerCount: 0,
      challengedCount: 0,
    );
  }

  factory PostStats.fromSnap(DataSnapshot snap) {
    final data = snap.value;

    if (snap.value == null) {
      return PostStats(likeCount: 0, commentCount: 0);
    }

    return PostStats(
      likeCount: data['like_count'] ?? 0,
      commentCount: data['comment_count'] ?? 0,
      challengerCount: data['challenger_like_count'] ?? 0,
      challengedCount: data['challenged_like_count'] ?? 0,
    );
  }
}
