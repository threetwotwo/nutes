import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutes/core/models/user.dart';

class Doodle {
  final User owner;
  final Timestamp timestamp;
  final String url;

  Doodle({this.owner, this.timestamp, this.url});

  factory Doodle.fromDoc(DocumentSnapshot doc) {
    final owner = User.fromMap(doc['owner']);
    final timestamp = doc['timestamp'] as Timestamp;

    return Doodle(
      owner: owner,
      timestamp: timestamp,
      url: doc['url'] ?? '',
    );
  }
}
