import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/events/events.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/events.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/comment_overlay.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/story_avatar.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/empty_view.dart';
import 'package:nutes/ui/widgets/feed_app_bar.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/ui/widgets/inline_stories.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback onCreatePressed;
  final VoidCallback onDM;
//  final VoidCallback onDoodleStart;
  final VoidCallback onDoodleEnd;
  final ScrollController scrollController;
//  final UserProfile profile;

  FeedScreen({
    Key key,
    this.onCreatePressed,
    this.onDM,
    this.scrollController,
//    this.onDoodleStart,
    this.onDoodleEnd,
//    @required this.profile,
  }) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin, RouteAware {
  final routeObserver = RouteObserver();

  Stream<QuerySnapshot> myStoryStream;

  final cache = LocalCache.instance;

  List<Post> posts = [];

  bool isFetchingPosts = false;

  ///Comment overlay fields
  Post commentingTo;
  bool showCommentTextField = false;
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

//  UserStory myStory;

  List<UserStory> followingsStories = [];

  DocumentSnapshot startAfter;

  User auth = FirestoreService.ath.user;

  Timer _debounce;

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
//    myStory = UserStory(
//      story: Story.empty(),
//      uploader: auth,
//      lastTimestamp: null,
//    );
    _getInitialPosts();
//    _getMyStory();
    _getStoriesOfFollowings();

    _refreshTimer();

    _checkForNewMessages();

    eventBus.on().listen((event) {
      if (event is StoryDeleteEvent) {
//        _getMyStory();
//        _getStoriesOfFollowings();
      } else
        _getInitialPosts();
    });

    super.initState();
  }

  _checkIfThereAreNewPosts() async {
    print('checking for new posts');
    final result = await Repo.checkIfThereAreNewPosts(posts.first.timestamp);

    if (result)
      setState(() {
        showThereAreNewPosts = true;
      });
    else
      _refreshTimer();
  }

  _refreshTimer() {
    print('refresh timer');
    setState(() {
      showThereAreNewPosts = false;
    });
    if (_debounce?.isActive ?? false) _debounce.cancel();

    _debounce = Timer(const Duration(seconds: 100), () {
      print(' timer up');

      if (posts.isNotEmpty) {
        _checkIfThereAreNewPosts();
      }
//      _refreshTimer();
    });
  }

  bool showThereAreNewPosts = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final topPadding = MediaQuery.of(context).padding.top;

    final profile = Provider.of<UserProfile>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FeedAppBar(
        onCreatePressed: widget.onCreatePressed,
//        onLogoutPressed: () => Repo.logout(),
        onDM: widget.onDM,
      ),
      body: profile == null
          ? LoadingIndicator()
          : CommentOverlay(
              onSend: (text) {
                if (commentingTo == null) return;

                final comment = Repo.createComment(
                  text: text,
                  postId: commentingTo.id,
                );
                Repo.uploadComment(post: commentingTo, comment: comment);
                final post =
                    posts.firstWhere((post) => post.id == commentingTo.id);

                if (mounted)
                  setState(() {
                    post.topComments.add(comment);
                    showCommentTextField = false;
                    commentingTo = null;
                  });
              },
              controller: commentController,
              focusNode: commentFocusNode,
              showTextField: showCommentTextField,
              onScroll: () {
//                print('on scroll');
                setState(() {
                  commentingTo = null;
                  showCommentTextField = false;
                });
                return;
              },
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: RefreshListView(
//          physics: isDoodling
//              ? NeverScrollableScrollPhysics()
//              : BouncingScrollPhysics(),
                      controller: widget.scrollController,
                      onRefresh: () {
                        _getStoriesOfFollowings();
                        return _getInitialPosts();
                      },
                      onLoadMore: _getMorePosts,
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                            stream: Repo.myStoryStream(),
                            builder: (context, storySnap) {
                              if (!storySnap.hasData) return LoadingIndicator();
                              final momentDocs = storySnap.data.documents;

                              final moments = momentDocs
                                  .map((doc) => Moment.fromDoc(doc))
                                  .toList();

                              final story = Story(
                                moments: moments,
                                isFinished: false,
                              );

                              final userStory = UserStory(
                                story: story,
                                uploader: profile.user,
                                lastTimestamp: moments.isEmpty
                                    ? null
                                    : moments[moments.length - 1].timestamp,
                              );

                              return Container(
                                height: 112,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.white,
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    Visibility(
                                      visible: story.moments.isEmpty,
                                      child: StoryAvatar(
                                        isOwner: true,
//                            user: User.empty(),

                                        user: profile.user,
                                        isEmpty: true,
                                        onTap: widget.onCreatePressed,
                                        onLongPress: widget.onCreatePressed,
                                      ),
                                    ),
                                    InlineStories(
                                      userStories: [
                                            if (story.moments.isNotEmpty)
                                              userStory
                                          ] +
                                          followingsStories,
//                          onCreateStory: widget.onCreatePressed,
                                      topPadding: topPadding,
                                    ),
                                  ],
                                ),
                              );
                            }),
                        Divider(),
                        isFetchingPosts
                            ? LoadingIndicator()
                            : posts.isEmpty
                                ? EmptyView(
                                    title: 'No posts to show',
                                    subtitle:
                                        'Start following users to see their posts',
                                  )
                                : PostListView(
                                    showEllipsis: true,
                                    posts: posts,
                                    onUnfollow: (uid) {
                                      print('onUnfollow $uid');
                                      return setState(() {
                                        posts = List<Post>.from(posts)
                                          ..removeWhere(
                                              (post) => post.owner.uid == uid);
                                      });
                                    },
                                    onAddComment: (post) {
                                      setState(() {
                                        commentingTo = post;
                                        showCommentTextField =
                                            !showCommentTextField;
                                      });
                                      FocusScope.of(context)
                                          .requestFocus(commentFocusNode);
                                      return;
                                    },
                                    onDoodleStart: _onDoodleStart,
                                    onDoodleEnd: _onDoodleEnd,
                                  ),
                        SizedBox(height: 64),
                      ],
                    ),
                  ),

                  ///New posts indicator
                  if (showThereAreNewPosts)
                    Align(
                      alignment: Alignment.topCenter,
                      child: FlatButton(
                        color: Colors.black.withOpacity(0.8),
                        shape: StadiumBorder(),
                        child: Text(
                          'New posts',
                          style:
                              TextStyles.w600Text.copyWith(color: Colors.white),
                        ),
                        onPressed: () async {
                          widget.scrollController.animateTo(0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);

//                          final result = await Repo.checkIfThereAreNewPosts(
//                              posts.first.timestamp);
//
//                          print('are there new posts? $result');
//
//                          if (result)
                          _getInitialPosts();
                          _refreshTimer();
                        },
                      ),
                    )
                ],
              ),
            ),
    );
  }

  Future<void> _getInitialPosts() async {
    if (mounted)
      setState(() {
//        startAfter = null;
        showThereAreNewPosts = false;
        isFetchingPosts = true;
      });

    final result = await Repo.getFeed();

    if (mounted)
      setState(() {
        posts = result.posts;
        startAfter = result.startAfter;
        isFetchingPosts = false;
      });
  }

  Future<void> _getMorePosts() async {
    if (posts.length < 4) return;

    final result = await Repo.getFeed(startAfter: startAfter);

    if (mounted)
      setState(() {
        posts = posts + result.posts;
        startAfter = result.startAfter;

//        if (result.posts.isEmpty) noMorePostsToLoad = true;
      });
  }

  ///TODO: sort the user stories
  Future<void> _getStoriesOfFollowings() async {
    final result = await Repo.getStoriesOfFollowings();

    result.sort(
        (a, b) => b.lastTimestamp.seconds.compareTo(a.lastTimestamp.seconds));

    setState(() {
      followingsStories = result;
    });
  }

  @override
  bool get wantKeepAlive => true;

//  void _getMyStory() async {
//    myStoryStream = Repo.myStoryStream();
//
//    ///Listen to changes to my story
//    myStoryStream.listen((event) {
//      List<Moment> moments = [];
//      List<Moment> removedMoments = [];
//
//      event.documentChanges.forEach((dc) {
//        final moment = Moment.fromDoc(dc.document);
////        print(dc.newIndex);
//        dc.newIndex < 0 ? removedMoments.add(moment) : moments.add(moment);
//      });
//
//      myStory.story.moments.removeWhere((m) =>
//          removedMoments.firstWhere((rm) => rm.id == m.id,
//              orElse: () => null) !=
//          null);
//
//      if (moments.isNotEmpty) myStory.story.moments.addAll(moments);
//
////      print('removed moments ._getMyStory: ${removedMoments.length}');
////      print('added moments ._getMyStory: ${moments.length}');
////      print('_FeedScreenState._getMyStory: ${myStory.story.moments.length}');
//
//      if (moments.isNotEmpty && mounted)
//        setState(() {
//          myStory = myStory.copyWith(
//              story: myStory.story,
//              lastTimestamp: moments[moments.length - 1].timestamp);
//        });
//    });
//  }

  bool isDoodling = false;
  VoidCallback _onDoodleStart() {
    print('feed on doodle');
    setState(() {
      isDoodling = true;
    });
//    return widget.onDoodleStart;
  }

  VoidCallback _onDoodleEnd() {
    setState(() {
      isDoodling = false;
    });
    return widget.onDoodleEnd;
  }

  void _checkForNewMessages() {}
}
