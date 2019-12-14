import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/home_model.dart';
import 'package:nutes/ui/shared/comment_overlay.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/story_avatar.dart';
import 'package:nutes/ui/widgets/feed_app_bar.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/core/services/locator.dart';
import 'package:nutes/ui/widgets/inline_stories.dart';
import 'package:flutter/cupertino.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback onCreatePressed;
  final VoidCallback onDM;
  final GlobalKey<NavigatorState> navigatorKey;

  final RouteObserver<PageRoute> routeObserver;
  FeedScreen(
      {Key key,
      this.onCreatePressed,
      this.onDM,
      this.navigatorKey,
//      this.onAddStoryPressed,
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

  ///Comment overlay fields
  String commentingTo;
  bool showCommentTextField = false;
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

  UserStory myStory = UserStory(
    story: Story.empty(),
    uploader: Auth.instance.profile.user,
    lastTimestamp: null,
  );

  List<UserStory> followingsStories = [];

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
  void initState() {
    _getPosts();
    _getMyStory();
    _getStoriesOfFollowings();
    super.initState();
  }

  bool headerRefreshIndicatorVisible = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FeedAppBar(
        onDM: widget.onDM,
        onCreatePressed: widget.onCreatePressed,
        onLogoutPressed: () => Repo.logout(),
      ),
      body: CommentOverlay(
        onSend: (text) {
          if (commentingTo == null) return;

          final comment = Repo.createComment(
            text: text,
            postId: commentingTo,
          );

          Repo.uploadComment(postId: commentingTo, comment: comment);
          final post = posts.firstWhere((post) => post.id == commentingTo);

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
          setState(() {
            commentingTo = null;
            showCommentTextField = false;
          });
          return;
        },
        child: RefreshListView(
          controller: cache.homeScrollController,
          onRefresh: () {
            _getStoriesOfFollowings();
            return _getPosts();
          },
          children: <Widget>[
            Container(
              height: 112,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: myStory == null
                  ? Center(child: LoadingIndicator())
                  : Row(
                      children: <Widget>[
//                        Visibility(
//                          visible: Repo.myStory == null
//                              ? false
//                              : Repo.myStory.moments.isEmpty &&
//                                  data.userStories.firstWhere(
//                                          (us) =>
//                                              us.uploader.uid ==
//                                              auth.profile.uid,
//                                          orElse: () => null) ==
//                                      null,
//                          child: Container(
////                                color: Colors.red,
//                            child: StoryAvatar(
//                              user: auth.profile.user,
//                              isEmpty: true,
//                              isFinished: true,
//                              onTap: widget.onCreatePressed,
//                              onLongPress: widget.onCreatePressed,
//                            ),
//                          ),
//                        ),
                        Visibility(
                          visible: myStory.story.moments.isEmpty,
                          child: StoryAvatar(
                            isOwner: true,
                            user: auth.profile.user,
                            isEmpty: true,
                            onTap: widget.onCreatePressed,
                            onLongPress: widget.onCreatePressed,
                          ),
                        ),
                        InlineStories(
                          userStories: [
                                if (myStory.story.moments.isNotEmpty) myStory
                              ] +
                              followingsStories,
                          onCreateStory: widget.onCreatePressed,
                          topPadding: topPadding,
                        ),
                      ],
                    ),
            ),
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
                    : PostListView(
                        posts: posts,
                        onUnfollow: (uid) {
                          print('onUnfollow $uid');
                          return setState(() {
                            posts = List.from(posts)
                              ..removeWhere((post) => post.owner.uid == uid);
                          });
                        },
                        onAddComment: (postId) {
                          print('add comment for post $postId');
                          setState(() {
                            commentingTo = postId;
                            showCommentTextField = !showCommentTextField;
                          });
                          FocusScope.of(context).requestFocus(commentFocusNode);
                          return;
                        })
          ],
        ),
      ),
    );
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

  ///TODO: sort the user stories
  Future<List<UserStory>> _getStoriesOfFollowings() async {
    final result = await Repo.getStoriesOfFollowings();
    setState(() {
      followingsStories = result;
    });
  }

  @override
  bool get wantKeepAlive => true;

  void _getMyStory() async {
    myStoryStream = Repo.myStoryStream();

    ///Listen to changes to my story
    myStoryStream.listen((event) {
      final moments = event.documentChanges
          .map((dc) => Moment.fromDoc(dc.document))
          .toList();

      myStory.story.moments.addAll(moments);

      if (moments.isNotEmpty && mounted)
        setState(() {
          myStory = myStory.copyWith(
              lastTimestamp: moments[moments.length - 1].timestamp);
        });
    });
  }
}
