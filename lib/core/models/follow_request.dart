import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutes/core/models/user.dart';

class FollowRequest {
  final Timestamp timeStamp;
  final User user;

  FollowRequest(this.timeStamp, this.user);
}
