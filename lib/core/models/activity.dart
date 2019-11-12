import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';

enum Activities {
  post_like,
  comment_like,
  follow,
}

class Activity {
  ///Owner of activity
  final User owner;

  ///Type of activity
  final Activities type;

  final String postId;

  final String postUrl;

  final Timestamp timestamp;

  final Map metadata;

  static Activities typeFromString(String val) {
    return Activities.values
        .firstWhere((b) => b.toString() == val, orElse: () => null);
  }

  static String typeStringVal(Activities type) {
    return type.toString().split('.')[1];
  }

  Activity({
    this.owner,
    this.type,
    this.postId,
    this.postUrl,
    this.metadata,
    this.timestamp,
  });

  factory Activity.fromDoc(DocumentSnapshot doc, List<User> followings) {
    final data = doc.data;

    final ownerId = data['owner_id'] ?? '';

    final owner =
        followings.firstWhere((f) => f.uid == ownerId, orElse: () => null);

    final type = Activity.typeFromString(data['type']);

    return Activity(
      owner: owner,
      type: type,
      postId: doc.documentID.split('-')[1],
      postUrl: data['post_url'] ?? '',
      metadata: data['metadata'],
      timestamp: data['timestamp'],
    );
  }
}
