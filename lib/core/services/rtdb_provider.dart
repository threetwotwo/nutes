import 'package:firebase_database/firebase_database.dart';
import 'package:nutes/core/models/user.dart';

class RTDBProvider {
  final _instance = FirebaseDatabase.instance;

  DatabaseReference postRef(String postId) {
    return _instance.reference().child('posts').child(postId);
  }

  Future<UserStats> getUserStats(String uid) async {
    UserStats stats;
    await _instance.reference().child('users').child(uid).once().then((snap) {
      stats = UserStats.fromSnap(snap);
    });
    return stats;
  }

//  Future<PostStats> getPostStats(String postId) async {
//    final postRef = this.postRef(postId);
//    final snap = await postRef.once();
//    return PostStats.fromSnap(snap);
//  }
}
