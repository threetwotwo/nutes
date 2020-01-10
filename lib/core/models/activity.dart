import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/models/user.dart';

enum ActivityType {
  post_like,
  comment_like,
  follow,
}

class ActivityBundle {
  final User owner;
  final List<Activity> activities;
  final ActivityType activityType;
  final Timestamp timestamp;

  ActivityBundle({
    this.owner,
    this.activities,
    this.activityType,
    this.timestamp,
  });

  factory ActivityBundle.from(List<Activity> activities, ActivityType type) {
    return ActivityBundle(
      owner: activities.last.activityOwner,
      activities: activities,
      timestamp: activities.first.timestamp,
      activityType: type,
    );
  }
}

class Activity {
  ///User who triggered the activity
  final User activityOwner;

  ///Type of activity
  final ActivityType activityType;

  ///User whom the activity owner engaged with eg. the user who was followed
  final User activiyPeer;

  ///Owner of activity
//  final User postOwner;

  final Post post;
//  final PostType postType;

//  final String postId;

//  final String postUrl;

  final Timestamp timestamp;

//  final Map metadata;

  static ActivityType typeFromString(String val) {
    return ActivityType.values.firstWhere(
        (b) => b.toString() == 'ActivityType.$val',
        orElse: () => null);
  }

  static String typeStringVal(ActivityType type) {
    return type.toString().split('.')[1];
  }

  Activity({
    @required this.activityOwner,
    this.activityType,
    this.activiyPeer,
//    this.postOwner,
    this.post,
//    this.postType,
//    this.postId,
//    this.postUrl,
//    this.metadata,
    this.timestamp,
  });

  factory Activity.fromDoc(DocumentSnapshot doc) {
    final activityType = Activity.typeFromString(doc['activity_type']);

    Map activityOwnerMap;
    Map activityPeerMap;

    switch (activityType) {
      case ActivityType.post_like:
        activityOwnerMap = doc['liker'];
        activityPeerMap = doc['owner'];
        break;
      case ActivityType.comment_like:
        // TODO: Handle this case.
        break;
      case ActivityType.follow:
        activityOwnerMap = doc['follower'];
        activityPeerMap = doc['following'];
        break;
    }

    final activityOwner = User.fromMap(activityOwnerMap ?? {});
    final activityPeer = User.fromMap(activityPeerMap ?? {});
//    final liker = User.fromMap(doc['liker'] ?? {});

//    final postType = PostHelper.postType(doc['type']);

    final post = Post.fromMap(doc.data);

    if (activityOwnerMap == null || activityPeerMap == null) return null;
    if (activityOwner.uid.isEmpty || activityPeer.uid.isEmpty) return null;

    return Activity(
      activityType: activityType,
//      postType: postType,
//      postId: doc.documentID.split('-')[1],
//      postOwner: activityPeer,
      activityOwner: activityOwner,
      activiyPeer: activityPeer,
//      postUrl: (doc['urls'] ?? []).isEmpty
//          ? ''
//          : (doc['urls'] ?? []).first['medium'] ?? '',
//      metadata: doc['metadata'],
      post: post,
      timestamp: doc['timestamp'],
    );
  }
}
