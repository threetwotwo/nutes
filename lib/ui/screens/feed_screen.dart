import 'package:flutter/material.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/home_model.dart';
import 'package:nutes/ui/shared/provider_view.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/story_avatar.dart';
import 'package:nutes/ui/widgets/feed_page_app_bar.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/core/services/locator.dart';
import 'package:nutes/core/view_models/feed_model.dart';
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

  final myStoryStream = Repo.myStoryStream();

//  final scrollController = Repo.homeScrollController;

  final cache = LocalCache.instance;

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
//    Repo.isHomeFirst = false;
    cache.homeIsFirst = false;

//    homeModel.changeScrollPhysics(NeverScrollableScrollPhysics());

    super.didPushNext();
  }

  @override
  void didPopNext() {
    print('did pop next: home');

//    Repo.isHomeFirst = true;
    cache.homeIsFirst = true;

//    homeModel.changeScrollPhysics(ClampingScrollPhysics());

    super.didPopNext();
  }

  Future<void> _handleRefresh() async {
    return _getSnapshotUserStories();
  }

  bool myStoryIsSEmpty;

  UStoryState myStoryState = UStoryState.none;

  @override
  void initState() {
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
          (us) => us.uploader.uid == Repo.currentProfile.uid,
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

      final userStory = UserStory(story, Repo.currentProfile.user);

      myStory != null
          ? Repo.snapshot.userStories[0] = userStory
          : Repo.snapshot.userStories.insert(0, userStory);

      Repo.refreshStream();

      if (mounted) setState(() {});
    });

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
        onLogoutPressed: () => _logout(context: context),
      ),
      body: ProviderView<FeedModel>(
        onModelReady: (model) {
          _getSnapshotUserStories();
          model.getInitialPosts();
        },
        builder: (context, model, child) => SafeArea(
          child: RefreshListView(
            controller: cache.homeScrollController,
            onRefresh: () {
              _getSnapshotUserStories();
              return model.getInitialPosts();
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
                                                  Repo.currentProfile.uid,
                                              orElse: () => null) ==
                                          null,
                              child: Container(
//                                color: Colors.red,
                                child: StoryAvatar(
                                  user: Repo.currentProfile.user,
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
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: model.posts.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.white,
                      child: PostListItem(
                        post: model.posts[index],
                        shouldNavigate: true,
                      ),
                    );
                  }),
            ],
          ),
//          child: CustomScrollView(
//            physics: AlwaysScrollableScrollPhysics(),
//            controller: Repo.homeScrollController,
//            slivers: <Widget>[
//              CupertinoSliverRefreshControl(
//                onRefresh: () {
//                  _getSnapshotUserStories();
//                  return model.getInitialPosts();
//                },
//                builder: (context, mode, _, __, ___) => Padding(
//                  padding: const EdgeInsets.all(20.0),
//                  child: CupertinoActivityIndicator(
//                    radius: 12,
//                  ),
//                ),
//              ),
//              SliverToBoxAdapter(
//                child: StreamBuilder<StorySnapshot>(
//                    stream: Repo.stream(),
//                    builder: (context, snapshot) {
//                      if (!snapshot.hasData) return SizedBox();
//
//                      final data = snapshot.data;
//
//                      return Container(
//                        height: 120,
//                        width: MediaQuery.of(context).size.width,
//                        color: Colors.white,
//                        child: SingleChildScrollView(
//                          physics: AlwaysScrollableScrollPhysics(),
//                          scrollDirection: Axis.horizontal,
//                          child: Row(
//                            children: <Widget>[
//                              Visibility(
//                                visible: Repo.myStory == null
//                                    ? false
//                                    : Repo.myStory.moments.isEmpty &&
//                                        data.userStories.firstWhere(
//                                                (us) =>
//                                                    us.uploader.uid ==
//                                                    Repo.currentProfile.uid,
//                                                orElse: () => null) ==
//                                            null,
//                                child: StoryAvatar(
//                                  user: Repo.currentProfile.user,
//                                  isEmpty: myStoryIsSEmpty,
//                                  isFinished: true,
//                                  onTap: widget.onAddStoryPressed,
//                                  onLongPress: widget.onAddStoryPressed,
//                                ),
//                              ),
//                              InlineStories(
//                                userStories: snapshot.data.userStories,
//                                onCreateStory: widget.onAddStoryPressed,
//                              ),
//                            ],
//                          ),
//                        ),
//                      );
//                    }),
//              ),
//              SliverToBoxAdapter(child: Divider()),
//              SliverToBoxAdapter(
//                child: ListView.builder(
//                    shrinkWrap: true,
//                    physics: NeverScrollableScrollPhysics(),
//                    itemCount: model.posts.length,
//                    itemBuilder: (context, index) {
//                      return Container(
//                        color: Colors.white,
//                        child: PostListItem(
//                          post: model.posts[index],
//                          shouldNavigate: true,
//                        ),
//                      );
//                    }),
//              )
//            ],
//          ),
        ),
      ),
    );
  }

  _logout({BuildContext context}) async {
    locator<LoginModel>().signOut();
  }

  Future<List<UserStory>> _getSnapshotUserStories() async {
    if (Repo.currentProfile == null) return [];
//    setState(ViewState.Busy);

    List<UserStory> stories = [];

    final myStory = await Repo.getStoryForUser(Repo.currentProfile.uid);
    Repo.myStory = myStory;

    final oldStories = Repo.snapshot.userStories;
    final newStories =
        await Repo.getSnapshotUserStories(userStories: oldStories);

    if (myStory.moments.isNotEmpty)
      stories.add(UserStory(myStory, Repo.currentProfile.user));

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
}
