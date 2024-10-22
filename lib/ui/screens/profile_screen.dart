import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/ui/screens/chat_screen.dart';
import 'package:nutes/ui/screens/follower_list_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/post_grid_view.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/widgets/empty_view.dart';
import 'package:nutes/ui/widgets/profile_header.dart';
import 'package:nutes/ui/widgets/profile_tab_controller.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/ui/screens/post_detail_screen.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/screens/edit_profile_page.dart';
import 'package:nutes/ui/widgets/story_page_view.dart';
import 'my_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool shouldNavigate;
  final VoidCallback onTrailingPressed;
  final String uid;
  final String username;

  ///Whether to show back button
  final bool isRoot;

  static Route<dynamic> routeUsername(String username) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        final profile = FirestoreService.ath;

        return username == profile.user.username
            ? MyProfileScreen()
            : ProfileScreen(username: username);
      },
    );
  }

  static Route<dynamic> route(String uid) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        final profile = FirestoreService.ath;

        return uid == profile.uid ? MyProfileScreen() : ProfileScreen(uid: uid);
      },
    );
  }

  const ProfileScreen({
    Key key,
    this.shouldNavigate = true,
    this.onTrailingPressed,
    this.isRoot = false,
    this.uid,
    this.username,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
//  bool isFollowing;
  ViewType view = ViewType.grid;
  DocumentSnapshot lastSnap;

  UserProfile profile;

  List<Post> posts = [];

  final cache = LocalCache.instance;

  String uid;

  bool isLoadingProfile = false;
  bool isLoadingPosts = false;

  UserStory userStory;

  DocumentSnapshot startAfter;

//  bool isBlocked = false;

  _init() async {
    print('init');
    uid = widget.uid;

    setState(() {
      isLoadingProfile = true;
    });

    if (uid == null) {
      final result = await Repo.getUserProfileFromUsername(widget.username);
      profile = result;
      if (result != null) uid = result.uid;
      setState(() {
        isLoadingProfile = false;
      });
    }

    if (uid == null) return;
    _getUserProfile();
    _getPosts();
  }

  _getUserProfile() async {
    print('getting user prof');

    var result = await Repo.getUserProfile(uid);

//    final myFollowRequests = await Repo.getMyFollowRequests();

//    result = result.copyWith(
//        hasRequestedFollow: myFollowRequests.contains(result.uid));

    if (mounted)
      setState(() {
        isLoadingProfile = false;
        profile = result;
      });

    final story = await Repo.getStoryForUser(uid);

    if (mounted)
      setState(() {
        userStory = UserStory(
            story: story,
            uploader: profile.user,
            lastTimestamp: story.moments.isEmpty
                ? null
                : story.moments[story.moments.length - 1].timestamp);
      });
  }

  @override
  initState() {
    super.initState();

    _init();
  }

  _getPosts() async {
    setState(() {
      isLoadingPosts = true;
    });
    final result = await Repo.getPostsForUser(
      uid: uid,
      limit: 8,
      startAfter: startAfter,
    );
    if (mounted)
      setState(() {
        isLoadingPosts = false;
        posts = result.posts;
        startAfter = result.startAfter;
      });
  }

  Future<void> _loadMore() async {
    final result = await Repo.getPostsForUser(
      uid: widget.uid,
      limit: 16,
      startAfter: startAfter,
    );

    setState(() {
      posts = posts + result.posts;
      startAfter = result.startAfter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    super.build(context);

    final myProfile = FirestoreService.ath;

    return profile == null
        ? SizedBox()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: BaseAppBar(
              title: Wrap(
                alignment: WrapAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    profile == null ? '' : profile.user.username,
                    style: TextStyles.header,
                  ),
                  if (profile.isVerified) ...[
                    SizedBox(width: 4),
                    Icon(
                      MdiIcons.checkDecagram,
                      color: Colors.blueAccent,
                      size: 18,
                    )
                  ],
                ],
              ),
              trailing: AspectRatio(
                aspectRatio: 1,
                child: InkWell(
                  onTap: () async {
                    final type = await showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child:
                                Text("Block", style: TextStyles.defaultDisplay),
                            onPressed: () {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title:
                                      Text('Block ${profile.user.username}?'),
                                  content: Text(
                                      "\nThey won't be able to find your profile, posts or story.\nYou will also stop receiving messages from them and unfollow them."),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: Text(
                                        'Block',
                                      ),
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        Repo.blockUser(profile.user);
                                        BotToast.showText(
                                            text: 'Account has been blocked',
                                            align: Alignment.center);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text(
                                        'Cancel',
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text("Report for spam",
                                style: TextStyles.defaultDisplay),
                            onPressed: () {
                              Navigator.pop(context, 'spam');
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text("Report for being inappropriate",
                                style: TextStyles.defaultDisplay),
                            onPressed: () {
                              Navigator.pop(context, 'inappropriate');
                            },
                          ),
                        ],
                        cancelButton: FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child:
                              Text('Cancel', style: TextStyles.defaultDisplay),
                        ),
                      ),
                    );

                    if (type != null && type is String) {
                      Repo.reportProfile(profile.user, type);

                      BotToast.showText(
                          text: 'Account has been reported',
                          align: Alignment.center);
                    }

//                    if (type != null && type is String) Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: DismissView(
                child: isLoadingProfile
                    ? LoadingIndicator()
                    : profile == null
                        ? SizedBox()
                        : StreamBuilder<DocumentSnapshot>(
                            stream: Repo.blockedUserStream(profile.uid),
                            builder: (context, blockedSnap) {
                              if (!blockedSnap.hasData) return SizedBox();

                              final isBlocked = blockedSnap.data.exists;

                              return StreamBuilder<DocumentSnapshot>(
                                  stream: Repo.amIFollowingUserStream(uid),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData || userStory == null)
                                      return Container();
                                    final imFollowingUser =
                                        snapshot.data.exists;
                                    return RefreshListView(
                                      onLoadMore: _loadMore,
                                      children: <Widget>[
                                        StreamBuilder<DocumentSnapshot>(
                                            stream: Repo.seenStoriesStream(),
                                            builder: (context, snapshot) {
                                              final data =
                                                  snapshot.data?.data ?? {};

                                              final Timestamp
                                                  seenStoryTimestamp =
                                                  data[userStory.uploader.uid];

                                              final storyState = userStory
                                                          .lastTimestamp ==
                                                      null
                                                  ? StoryState.none
                                                  : seenStoryTimestamp == null
                                                      ? StoryState.unseen
                                                      : seenStoryTimestamp
                                                                  .seconds <
                                                              userStory
                                                                  .lastTimestamp
                                                                  .seconds
                                                          ? StoryState.unseen
                                                          : StoryState.seen;

                                              return StreamBuilder<
                                                      DocumentSnapshot>(
                                                  stream: Repo
                                                      .myFollowRequestStream(),
                                                  builder: (context, s) {
                                                    if (!s.hasData)
                                                      return SizedBox();

                                                    final List requests = s
                                                                .data.data ==
                                                            null
                                                        ? []
                                                        : s.data['requests'] ??
                                                            [];

                                                    return ProfileHeader(
                                                      isBlocked: isBlocked,
                                                      onUnblock: () {
                                                        print(
                                                            'unblock user ${profile.user.username}');
                                                        return Repo.unblockUser(
                                                            profile.user);
                                                      },
                                                      hasRequest:
                                                          requests.contains(
                                                              profile.uid),
                                                      storyState: storyState,
                                                      onAvatarPressed: () =>
                                                          userStory ==
                                                                      null ||
                                                                  userStory
                                                                      .story
                                                                      .moments
                                                                      .isEmpty
                                                              ? () {}
                                                              : StoryPageView.show(
                                                                  context,
                                                                  initialPage:
                                                                      0,
                                                                  topPadding:
                                                                      topPadding,
                                                                  userStories: [
                                                                    userStory
                                                                  ],
                                                                  onPageChange:
                                                                      (val) {}),
                                                      isFollowing:
                                                          imFollowingUser,
                                                      isOwner: false,
                                                      profile: profile,
                                                      onFollowersPressed: () =>
                                                          Navigator.push(
                                                              context,
                                                              FollowerListScreen
                                                                  .route(
                                                                      profile
                                                                          .user,
                                                                      0)),
                                                      onFollowingsPressed: () =>
                                                          Navigator.push(
                                                              context,
                                                              FollowerListScreen
                                                                  .route(
                                                                      profile
                                                                          .user,
                                                                      1)),
                                                      onMessagePressed: () =>
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatScreen(
                                                            peer: profile.user,
                                                          ),
                                                        ),
                                                      ),
                                                      onEditPressed:
                                                          profile == null
                                                              ? null
                                                              : () {
                                                                  return Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .push(MaterialPageRoute(
                                                                          fullscreenDialog:
                                                                              true,
                                                                          builder: (ctx) =>
                                                                              EditProfilePage()));
                                                                },
                                                      onFollow: () {
                                                        if (profile
                                                            .user.isPrivate) {
//
                                                          if (imFollowingUser)
                                                            Repo.unfollowUser(
                                                                profile.uid);

                                                          return Repo
                                                              .requestFollow(
                                                                  profile.user);
                                                        } else {
                                                          if (imFollowingUser) {
                                                            Repo.unfollowUser(
                                                                profile.uid);

                                                            if (mounted)
                                                              setState(() {
                                                                profile = profile.copyWith(
                                                                    followerCount:
                                                                        profile.stats.followerCount -
                                                                            1);
                                                              });
                                                          } else {
                                                            Repo.requestFollow(
                                                                profile.user);
                                                            if (mounted)
                                                              setState(() {
//                                                    isFollowing = true;
                                                                profile = profile.copyWith(
                                                                    followerCount:
                                                                        profile.stats.followerCount +
                                                                            1);
                                                              });
                                                          }
                                                        }
                                                      },
                                                      onRequest: () {
                                                        print(
                                                            'on request follow');
                                                        Repo.deleteFollowRequest(
                                                            myProfile.uid,
                                                            profile.uid);
                                                      },
                                                    );
                                                  });
                                            }),
                                        Divider(height: 0, thickness: 1),
                                        profile.user.isPrivate == null
                                            ? SizedBox()
                                            : profile.user.isPrivate &&
                                                    !(imFollowingUser)
                                                ? PrivateAccount()
                                                : isLoadingPosts
                                                    ? LoadingIndicator()
                                                    : posts.isEmpty
                                                        ? EmptyView(
                                                            title:
                                                                'No Posts Yet',
                                                            subtitle:
                                                                'When ${profile.user.username} posts, you will see their photos here',
                                                          )
                                                        : ProfileTabController(
                                                            view: view,
                                                            postGridView:
                                                                PostGridView(
                                                              posts: posts,
                                                              onTap: (index) => Navigator
                                                                      .of(context)
                                                                  .push(MaterialPageRoute(
                                                                      builder: (context) => PostDetailScreen(
                                                                            post:
                                                                                posts[index],
                                                                          ))),
                                                            ),
                                                            postListView:
                                                                ListView
                                                                    .builder(
                                                              shrinkWrap: true,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              itemCount:
                                                                  posts.length,
                                                              itemBuilder: (context,
                                                                      index) =>
                                                                  PostListItem(
                                                                shouldNavigate:
                                                                    true,
                                                                post: posts[
                                                                    index],
                                                              ),
                                                            )),
                                      ],
                                    );
                                  });
                            },
                          ),
              ),
            ));
  }

  @override
  bool get wantKeepAlive => true;
}

class PrivateAccount extends StatelessWidget {
  const PrivateAccount({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(9999))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  LineIcons.lock,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'This Account is Private',
              style: TextStyles.w600Text.copyWith(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Follow to view posts',
              style: TextStyles.w300Display.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
