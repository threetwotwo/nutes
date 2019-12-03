import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/login_model.dart';
import 'package:nutes/ui/screens/edit_profile_page.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/follower_list_screen.dart';
import 'package:nutes/ui/screens/post_detail_page.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/post_grid_view.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/profile_header.dart';
import 'package:nutes/ui/widgets/profile_screen_widgets.dart';
import 'package:nutes/ui/widgets/story_page_view.dart';
import 'package:provider/provider.dart';

import 'account_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final bool isRoot;

  MyProfileScreen({Key key, this.isRoot = false}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
//  UserProfile profile;

  final profileStream = Repo.myRef().snapshots();
  final auth = Auth.instance;

  final postStream = Repo.myPostStream();

  final cache = LocalCache.instance;
  ViewType view = ViewType.grid;

  @override
  void initState() {
//    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    print('top padding $topPadding');

    return Scaffold(
      appBar: ProfileAppBar(
        profile: auth.profile,
        isRoot: widget.isRoot,
        onTrailingPressed: () =>
            Navigator.push(context, AccountScreen.route(auth.profile)),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: RefreshListView(
        controller: widget.isRoot ? cache.profileScrollController : null,
        children: <Widget>[
          StreamBuilder<DocumentSnapshot>(
              stream: profileStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                    color: Colors.red,
                    child: Text('no profile stream data'),
                  );

                final prof = UserProfile.fromDoc(snapshot.data);

                print('my data: ${snapshot.data.data}');
                return StreamBuilder<QuerySnapshot>(
                    stream: Repo.myStoryStream(),
                    builder: (context, storySnap) {
                      if (!storySnap.hasData)
                        return Container(
                          color: Colors.blue,
                          child: Text('no my story stream data'),
                        );
                      final momentDocs = storySnap.data.documents;

                      final moments =
                          momentDocs.map((doc) => Moment.fromDoc(doc)).toList();

                      final story = Story(
                          startAt: 0,
                          lastLoaded: 0,
                          moments: moments,
                          isFinished: false);

                      final userStory = UserStory(story, auth.profile.user);

                      return ProfileHeader(
                        onAvatarPressed: () => momentDocs.isNotEmpty
                            ? StoryPageView.show(
                                context, 0, [userStory], topPadding)
                            : Navigator.of(context, rootNavigator: true)
                                .push(EditorPage.route()),
                        onFollowersPressed: () => Navigator.push(context,
                            FollowerListScreen.route(auth.profile.user, 0)),
                        onFollowingsPressed: () => Navigator.push(context,
                            FollowerListScreen.route(auth.profile.user, 1)),
                        hasStories: momentDocs.isNotEmpty,
                        profile: prof,
                        isOwner: true,
                        isFollowing: false,
                        onEditPressed: () async {
                          final UserProfile updatedProfile =
                              await Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (ctx) => EditProfilePage(
                                            profile: prof,
                                          )));

                          if (updatedProfile != null)

                            ///Dont trigger if user cancel edit profile
                            setState(() {
                              auth.profile = updatedProfile;
//                                    model.updateProfile(updatedProfile);
//                                    profile = updatedProfile;
                            });
                        },
                      );
                    });
              }),
          Divider(height: 0, thickness: 1),
          StreamBuilder<QuerySnapshot>(
              stream: postStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                      padding: const EdgeInsets.all(8),
                      child: CupertinoActivityIndicator());
                final docs = snapshot.data.documents;
                var posts = docs.map((doc) => Post.fromDoc(doc)).toList();
                posts.removeWhere((p) => p == null);

                return posts.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: <Widget>[
//                              Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Icon(
//                                  LineIcons.group,
//                                  color: Colors.grey,
//                                  size: 50,
//                                ),
//                              ),
                              Text(
                                'You have no posts. \n',
                                style: TextStyles.defaultDisplay.copyWith(
                                  color: Colors.grey,
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Create your first post',
                                style: TextStyles.defaultDisplay.copyWith(
                                  color: Colors.grey,
//                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              RaisedButton.icon(
                                color: Colors.blue,
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .push(EditorPage.route()),
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Create Post',
                                  style: TextStyles.w600Text
                                      .copyWith(color: Colors.white),
                                ),
                                shape: StadiumBorder(),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      )
                    : PostMasterView(
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
                        ));
              }),
        ],
      )),
    );
  }
}
