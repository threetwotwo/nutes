import 'package:nutes/ui/widgets/profile_screen_widgets.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel extends BaseModel {
  DocumentSnapshot snap;

  User user;

  ProfileModel({this.user});

  List<Post> posts = [];

  ViewType view = ViewType.grid;

  bool hasFollowRequest = false;

  void redactFollowRequest() {
    this.hasFollowRequest = false;

    Repo.redactFollowRequest(user.uid, Repo.currentProfile.uid);

    notifyListeners();
  }

  changeViewType(ViewType view) {
    this.view = view;
    notifyListeners();
  }

  follow(User user, bool isPrivate) {
    if (isPrivate) hasFollowRequest = true;

    Repo.requestFollow(user, isPrivate);

    //TODO: update stories snapshot array

    notifyListeners();
  }

  void updateUser(User user) {
    this.user = user;
    notifyListeners();
  }

  getPosts(String uid) async {
//    if (user != null)
    posts = await Repo.getPostsForUser(uid: uid, limit: 10);
    notifyListeners();
  }

  void refresh() {}

//  Stream<List<Post>> postStream(String uid) {
//    return FirestoreService().getPostsWithoutStatsStream(uid: uid, limit: 10);
//  }

  @override
  void dispose() {
    print('profilemodel disposed');

    super.dispose();
  }
}
