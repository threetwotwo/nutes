import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/base_model.dart';

class FeedModel extends BaseModel {
  List<Post> posts = [];

  @override
  void dispose() {
    print('feedmodel disposed');
    super.dispose();
  }

  Future<List<UserStory>> getSnapshotUserStories() async {
    if (Repo.currentProfile == null) return [];
//    setState(ViewState.Busy);

    List<UserStory> stories = [];

    final myStory = await Repo.getStoryForUser(Repo.currentProfile.uid);
    Repo.myStory = myStory;
    print(myStory.moments.length);
    final newStories = await Repo.getSnapshotUserStories();

    if (myStory.moments.isNotEmpty)
      stories.add(UserStory(myStory, Repo.currentProfile.user));
    stories.addAll(newStories);

    print('stories: ${stories.map((s) => s.uploader.username).toList()}');

    Repo.updateUserStories(stories);
    Repo.refreshStream();
    return newStories;
  }

  Future<void> getInitialPosts() async {
    print('getinitposts');
    if (Repo.currentProfile == null) return;
    posts.clear();
    setState(ViewState.Busy);
    final newPosts =
        await Repo.getFeed(uid: Repo.currentProfile.uid, limit: 10);
    posts = newPosts;
//    setState(ViewState.Idle);
    notify();
  }
}
