import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/events/events.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/events.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/edit_profile_page.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/follower_list_screen.dart';
import 'package:nutes/ui/screens/post_detail_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/post_grid_view.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/widgets/my_empty_post_view.dart';
import 'package:nutes/ui/widgets/profile_header.dart';
import 'package:nutes/ui/widgets/profile_tab_controller.dart';
import 'package:nutes/ui/widgets/story_page_view.dart';

import 'account_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final bool isRoot;
  final ScrollController scrollController;
//  final UserProfile profile;

  MyProfileScreen({
    Key key,
    this.isRoot = false,
    this.scrollController,
//    this.profile,
  }) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final profileStream = Repo.myRef().snapshots();

  final postStream = Repo.myPostStream();

  final cache = LocalCache.instance;
  ViewType view = ViewType.grid;

  bool isLoadingPosts = false;

  bool initialPostsLoaded = false;

  DocumentSnapshot startAfter;

  List<Post> posts = [];

  final profile = FirestoreService.ath;

  Future<void> _getInitialPosts() async {
    setState(() {
      isLoadingPosts = true;
    });
    final result = await Repo.getPostsForUser(
      uid: profile.uid,
      limit: 10,
      startAfter: null,
    );
    if (mounted)
      setState(() {
        isLoadingPosts = false;
        posts = result.posts;
        startAfter = result.startAfter;
        initialPostsLoaded = true;
      });
  }

  Future<void> _loadMore() async {
//    final auth = Provider.of<UserProfile>(context);

    final result = await Repo.getPostsForUser(
      uid: profile.uid,
      limit: 10,
      startAfter: startAfter,
    );

    setState(() {
      posts = posts + result.posts;
      startAfter = result.startAfter;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _getInitialPosts();

    postStream.listen((data) {
      data.documents.forEach((doc) {
        if (initialPostsLoaded) {
          final post = Post.fromDoc(doc);

          if (post == null) return;

          setState(() {
            posts = [post] + posts;
          });
        }
      });
    });

    eventBus.on<PostDeleteEvent>().listen((event) {
      setState(() {
        posts = List<Post>.from(posts)
          ..removeWhere((p) => p.id == event.postId);
      });
    });
    eventBus.on<ProfileUpdateEvent>().listen((event) {
      _getInitialPosts();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
//    final auth = Provider.of<UserProfile>(context);

    return StreamBuilder<DocumentSnapshot>(
        stream: profileStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoadingIndicator();

          final prof = UserProfile.fromDoc(snapshot.data);
          return Scaffold(
            appBar: ProfileAppBar(
              profile: prof,
              isRoot: widget.isRoot,
              onTrailingPressed: () =>
                  Navigator.push(context, AccountScreen.route(profile)),
            ),
            backgroundColor: Colors.white,
            body: SafeArea(
                child: RefreshListView(
              onRefresh: _getInitialPosts,
              onLoadMore: _loadMore,
              controller: widget.isRoot ? widget.scrollController : null,
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                    stream: Repo.myStoryStream(),
                    builder: (context, storySnap) {
                      if (!storySnap.hasData) return LoadingIndicator();
                      final momentDocs = storySnap.data.documents;

                      final moments =
                          momentDocs.map((doc) => Moment.fromDoc(doc)).toList();

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

                      return StreamBuilder<DocumentSnapshot>(
                          stream: Repo.seenStoriesStream(),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data ?? {};

                            final Timestamp seenStoryTimestamp =
                                data[userStory.uploader.uid];

                            final storyState = userStory.lastTimestamp == null
                                ? StoryState.none
                                : seenStoryTimestamp == null
                                    ? StoryState.unseen
                                    : seenStoryTimestamp.seconds <
                                            userStory.lastTimestamp.seconds
                                        ? StoryState.unseen
                                        : StoryState.seen;

                            return ProfileHeader(
                              onAvatarPressed: () => momentDocs.isNotEmpty
                                  ? StoryPageView.show(context,
                                      initialPage: 0,
                                      topPadding: topPadding,
                                      userStories: [userStory],
                                      onPageChange: (val) {})
                                  : Navigator.of(context, rootNavigator: true)
                                      .push(EditorPage.route()),
                              onFollowersPressed: () => Navigator.push(context,
                                  FollowerListScreen.route(prof.user, 0)),
                              onFollowingsPressed: () => Navigator.push(context,
                                  FollowerListScreen.route(prof.user, 1)),
                              storyState: storyState,
                              profile: prof,
                              isOwner: true,
                              isFollowing: false,
                              onEditPressed: () async {
                                final UserProfile updatedProfile =
                                    await Navigator.of(context,
                                            rootNavigator: true)
                                        .push(MaterialPageRoute(
                                            fullscreenDialog: true,
                                            builder: (ctx) => EditProfilePage(
                                                  profile: prof,
                                                )));

                                if (updatedProfile != null)

                                  ///Dont trigger if user cancel edit profile
                                  setState(() {
//                                    globals.profile = updatedProfile;
//                                    model.updateProfile(updatedProfile);
//                                    profile = updatedProfile;
                                  });
                              },
                            );
                          });
                    }),
                Divider(height: 0, thickness: 1),
                isLoadingPosts
                    ? LoadingIndicator()
                    : posts.isEmpty
                        ? MyEmptyPostView()
                        : ProfileTabController(
                            view: view,
                            postGridView: PostGridView(
                              posts: posts,
                              onTap: (index) =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => PostDetailScreen(
                                            post: posts[index],
                                          ))),
                            ),
                            postListView: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              itemBuilder: (context, index) => PostListItem(
                                post: posts[index],
                              ),
                            )),
              ],
            )),
          );
        });
  }
}
