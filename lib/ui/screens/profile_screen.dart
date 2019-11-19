import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/ui/screens/chat_screen.dart';
import 'package:nutes/ui/screens/follower_list_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/post_grid_view.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/widgets/profile_header.dart';
import 'package:nutes/ui/widgets/profile_screen_widgets.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/ui/screens/post_detail_page.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/screens/edit_profile_page.dart';

import 'my_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool shouldNavigate;
  final VoidCallback onTrailingPressed;
  final String uid;

  ///Whether to show back button
  final bool isRoot;

  static Route<dynamic> route(String uid) {
    return MaterialPageRoute(
      builder: (BuildContext context) => uid == Repo.currentProfile.uid
          ? MyProfileScreen()
          : ProfileScreen(uid: uid),
    );
  }

  const ProfileScreen({
    Key key,
    this.shouldNavigate = true,
    this.onTrailingPressed,
    this.isRoot = false,
    @required this.uid,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  bool isFollowing;
  ViewType view = ViewType.grid;
  DocumentSnapshot lastSnap;

  UserProfile profile;

  List<Post> posts = [];

  Stream<DocumentSnapshot> _myFollowingStream;

  final cache = LocalCache.instance;

  _getUser() async {
    var result = await Repo.getUserProfile(widget.uid);
    final myFollowRequests = await Repo.getMyFollowRequests();

    result = result.copyWith(
        hasRequestedFollow: myFollowRequests.contains(result.uid));

    if (mounted)
      setState(() {
        profile = result;
      });
  }

  @override
  initState() {
    super.initState();

    _getPosts();

    _myFollowingStream = Repo.myFollowingListStream();

    _getUser();
  }

  _getPosts() async {
    final result = await Repo.getPostsForUser(uid: widget.uid, limit: 10);
    if (mounted)
      setState(() {
        posts = result;
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          title: Text(
            profile == null ? '' : profile.user.username,
            style: TextStyles.W500Text15.copyWith(fontSize: 16),
          ),
          onTrailingPressed: () {
            final route = ModalRoute.of(context);
            print(route.isFirst);
          },
          trailing: Icon(
            LineIcons.ellipsis_h,
            color: Colors.black,
          ),
        ),
        body: SafeArea(
          child: DismissView(
            onDismiss: () => Navigator.pop(context),
            child: StreamBuilder<DocumentSnapshot>(
                stream: _myFollowingStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  final List uids = snapshot.data.data == null
                      ? []
                      : snapshot.data.data['uids'];
                  return (profile == null)
                      ? GestureDetector(
                          onHorizontalDragUpdate: (_) {},
                          child: Container(
                            color: Colors.white,
                          ))
                      : RefreshListView(
                          onLoadMore: () {},
//                            controller: cache.profileScrollController,
                          children: <Widget>[
                            ProfileHeader(
                              hasStories: false,
                              isFollowing:
                                  isFollowing ?? uids.contains(widget.uid),
                              isOwner: false,
                              profile: profile,
                              onFollowersPressed: () => Navigator.push(context,
                                  FollowerListScreen.route(profile.user, 0)),
                              onFollowingsPressed: () => Navigator.push(context,
                                  FollowerListScreen.route(profile.user, 1)),
                              onMessagePressed: () =>
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    peer: profile.user,
                                  ),
                                ),
                              ),
                              onEditPressed: profile == null
                                  ? null
                                  : () {
                                      return Navigator.of(context,
                                              rootNavigator: true)
                                          .push(MaterialPageRoute(
                                              fullscreenDialog: true,
                                              builder: (ctx) =>
                                                  EditProfilePage()));
                                    },
                              onFollow: () {
                                if (profile.user.isPrivate) {
                                  setState(() {
                                    profile = profile.copyWith(
                                        hasRequestedFollow: true);
                                  });
                                  return Repo.requestFollow(
                                      profile.user, profile.user.isPrivate);
                                }

                                if (isFollowing ?? uids.contains(widget.uid)) {
                                  print('unfollow');

                                  Repo.unfollowUser(profile.uid);

                                  if (mounted)
                                    setState(() {
                                      isFollowing = false;
                                      profile = profile.copyWith(
                                          followerCount:
                                              profile.stats.followerCount - 1);
                                    });
                                } else {
                                  print('follow');
                                  Repo.requestFollow(
                                      profile.user, profile.user.isPrivate);
                                  if (mounted)
                                    setState(() {
                                      isFollowing = true;
                                      profile = profile.copyWith(
                                          followerCount:
                                              profile.stats.followerCount + 1);
                                    });
                                }
                              },
                              onRequest: () {
                                setState(() {
                                  profile = profile.copyWith(
                                      hasRequestedFollow: false);
                                });
                                Repo.redactFollowRequest(
                                    Repo.currentProfile.uid, profile.uid);
                              },
                            ),
                            Divider(height: 0, thickness: 1),
                            profile.user.isPrivate == null
                                ? SizedBox()
                                : profile.user.isPrivate &&
                                        !(uids.contains(profile.uid))
                                    ? PrivateAccount()
                                    : PostMasterView(
                                        view: view,
                                        postGridView: PostGridView(
                                          posts: posts,
                                          onTap: (index) =>
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PostDetailScreen(
                                                            post: posts[index],
                                                          ))),
                                        ),
                                        postListView: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: posts.length,
                                          itemBuilder: (context, index) =>
                                              PostListItem(
                                            shouldNavigate: true,
                                            post: posts[index],
                                          ),
                                        )),
                          ],
                        );
                }),
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;

  _changeView(ViewType view) {
    if (mounted)
      setState(() {
        this.view = view;
      });
  }
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
              style: TextStyles.W500Text15.copyWith(fontSize: 16),
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
