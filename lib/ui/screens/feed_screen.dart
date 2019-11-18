import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/home_model.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/story_avatar.dart';
import 'package:nutes/ui/widgets/feed_page_app_bar.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/core/services/locator.dart';
import 'package:nutes/core/view_models/login_model.dart';
import 'package:nutes/ui/widgets/inline_stories.dart';
import 'package:flutter/cupertino.dart';

class FeedScreen extends StatefulWidget {
  final Function onCreatePressed;
  final GlobalKey<NavigatorState> navigatorKey;

  final VoidCallback onAddStoryPressed;
  final RouteObserver<PageRoute> routeObserver;
  FeedScreen(
      {Key key,
      this.onCreatePressed,
      this.navigatorKey,
      this.onAddStoryPressed,
      this.routeObserver})
      : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin, RouteAware {
  final homeModel = locator<HomeModel>();

  final routeObserver = locator<RouteObserver<PageRoute>>();

  Stream<QuerySnapshot> myStoryStream;

  final auth = Auth.instance;
  final cache = LocalCache.instance;

  List<Post> posts = [];

  bool isFetchingPosts = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    print('did push next: home');
    cache.homeIsFirst = false;

    super.didPushNext();
  }

  @override
  void didPopNext() {
    print('did pop next: home');

    cache.homeIsFirst = true;

    super.didPopNext();
  }

  bool myStoryIsSEmpty;

  UStoryState myStoryState = UStoryState.none;

  @override
  void initState() {
    _getPosts();
    _getSnapshotUserStories();

    _getMyStory();

    super.initState();
  }

  bool headerRefreshIndicatorVisible = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FeedPageAppBar(
        onCreatePressed: widget.onCreatePressed,
        onLogoutPressed: () => Repo.logout(),
      ),
      body: RefreshListView(
        controller: cache.homeScrollController,
        onRefresh: () {
          _getSnapshotUserStories();
          return _getPosts();
        },
        children: <Widget>[
          StreamBuilder<StorySnapshot>(
              stream: Repo.stream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();

                final data = snapshot.data;

                return Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        Visibility(
                          visible: Repo.myStory == null
                              ? false
                              : Repo.myStory.moments.isEmpty &&
                                  data.userStories.firstWhere(
                                          (us) =>
                                              us.uploader.uid ==
                                              auth.profile.uid,
                                          orElse: () => null) ==
                                      null,
                          child: Container(
//                                color: Colors.red,
                            child: StoryAvatar(
                              user: auth.profile.user,
                              isEmpty: true,
                              isFinished: true,
                              onTap: widget.onAddStoryPressed,
                              onLongPress: widget.onAddStoryPressed,
                            ),
                          ),
                        ),
                        InlineStories(
                          userStories: snapshot.data.userStories,
                          onCreateStory: widget.onAddStoryPressed,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          Divider(),
          isFetchingPosts
              ? Padding(
                  padding: EdgeInsets.all(8),
                  child: CupertinoActivityIndicator(),
                )
              : posts.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(24),
//                          color: Colors.red,
                      child: Center(
                          child: Text(
                        'No posts to show. \n Start '
                        'following users to see their posts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      )),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.white,
                          child: PostListItem(
                            post: posts[index],
                            shouldNavigate: true,
                          ),
                        );
                      }),
        ],
      ),
    );
  }

  _logout({BuildContext context}) async {
    locator<LoginModel>().signOut();
  }

  Future<List<Post>> _getPosts() async {
    if (mounted)
      setState(() {
        isFetchingPosts = true;
      });

    final result = await Repo.getFeed(uid: auth.profile.uid, limit: 10);

    if (mounted)
      setState(() {
        posts = result;
        isFetchingPosts = false;
      });
  }

  Future<List<UserStory>> _getSnapshotUserStories() async {
    List<UserStory> stories = [];

    final myStory = await Repo.getStoryForUser(auth.profile.uid);
    Repo.myStory = myStory;

    final oldStories = Repo.snapshot.userStories;
    final newStories =
        await Repo.getSnapshotUserStories(userStories: oldStories);

    if (myStory.moments.isNotEmpty)
      stories.add(UserStory(myStory, auth.profile.user));

    newStories.forEach((us) {
      print(us);
      final match = oldStories.firstWhere(
          (os) => os.uploader.uid == us.uploader.uid,
          orElse: () => null);
      if (match != null && match.story != null) {
        print(
            'match ${match.uploader.username} start at ${match.story.startAt}');

        ///Set isFinished to false if true
        final isThereNewMoment =
            us.story.moments.length > match.story.moments.length;

        us = UserStory(
            us.story.copyWith(
                startAt: match.story.startAt,
                isFinished: isThereNewMoment ? false : us.story.isFinished),
            us.uploader);
      } else {
        print('no match');
      }
    });

    stories.addAll(newStories);

    Repo.updateUserStories(stories);
    Repo.refreshStream();
    return newStories;
  }

  @override
  bool get wantKeepAlive => true;

  void _getMyStory() async {
    myStoryStream = Repo.myStoryStream();

    ///Listen to changes to my story
    myStoryStream.listen((event) {
      if (event.documentChanges.isEmpty) return;

      final moments = event.documentChanges
          .map((dc) => Moment.fromDoc(dc.document))
          .toList();

      setState(() {
        myStoryIsSEmpty = moments.isEmpty;
      });

      final myStory = Repo.snapshot.userStories.firstWhere(
          (us) => us.uploader.uid == auth.profile.uid,
          orElse: () => null);

      Story story;

      if (myStory != null) {
        print('my story exists, should append new moments');
        story = Story(
            startAt: myStory.story.moments.length,
            lastLoaded: 0,
            moments: myStory.story.moments + moments);
      } else {
        print('i dont have any moments to show');
        story = Story(startAt: 0, lastLoaded: 0, moments: moments);
      }

      final userStory = UserStory(story, auth.profile.user);

      myStory != null
          ? Repo.snapshot.userStories[0] = userStory
          : Repo.snapshot.userStories.insert(0, userStory);

      Repo.refreshStream();

      if (mounted) setState(() {});
    });
  }
}
