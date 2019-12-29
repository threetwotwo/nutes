import 'package:cloud_firestore/cloud_firestore.dart';
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
      owner: activities.last.liker,
      activities: activities,
      timestamp: activities.first.timestamp,
      activityType: type,
    );
  }
}

class Activity {
  ///Owner of activity
  final User postOwner;

  ///User who liked the post
  final User liker;

  ///Type of activity
  final ActivityType activityType;

  final PostType postType;

  final String postId;

  final String postUrl;

  final Timestamp timestamp;

  final Map metadata;

  static ActivityType typeFromString(String val) {
    return ActivityType.values.firstWhere(
        (b) => b.toString() == 'ActivityType.$val',
        orElse: () => null);
  }

  static String typeStringVal(ActivityType type) {
    return type.toString().split('.')[1];
  }

  Activity({
    this.postOwner,
    this.activityType,
    this.postType,
    this.postId,
    this.postUrl,
    this.metadata,
    this.timestamp,
    this.liker,
  });

  factory Activity.fromDoc(DocumentSnapshot doc) {
    final owner = User.fromMap(doc['owner'] ?? {});
    final liker = User.fromMap(doc['liker'] ?? {});

    final activityType = Activity.typeFromString(doc['activity_type']);

    final postType = PostHelper.postType(doc['type']);

    return Activity(
      activityType: activityType,
      postType: postType,
      postId: doc.documentID.split('-')[1],
      postOwner: owner,
      liker: liker,
      postUrl: (doc['urls'] ?? []).isEmpty
          ? ''
          : (doc['urls'] ?? []).first['medium'] ?? '',
      metadata: doc['metadata'],
      timestamp: doc['timestamp'],
    );
  }
}
