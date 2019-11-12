import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/edit_profile_page.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/post_detail_page.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/post_grid_view.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/profile_header.dart';
import 'package:nutes/ui/widgets/profile_screen_widgets.dart';
import 'package:nutes/ui/widgets/story_page_view.dart';

import 'account_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final bool isRoot;

  MyProfileScreen({Key key, this.isRoot = false}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  UserProfile profile = Repo.currentProfile;

  final profileStream = Repo.myRef().snapshots();

  final storyStream = Repo.myStoryStream();
  final postStream = Repo.myPostStream();

  final cache = LocalCache.instance;
  ViewType view = ViewType.grid;

//  List<Post> posts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(
        profile: profile,
        isRoot: widget.isRoot,
        onTrailingPressed: () =>
            Navigator.push(context, AccountScreen.route(profile)),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: RefreshListView(
        controller: cache.profileScrollController,
        children: <Widget>[
          StreamBuilder<DocumentSnapshot>(
              stream: profileStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();

                final prof = UserProfile.fromDoc(snapshot.data);

                print('my data: ${snapshot.data.data}');
                return StreamBuilder<QuerySnapshot>(
                    stream: storyStream,
                    builder: (context, storySnap) {
                      if (!storySnap.hasData) return SizedBox();
                      final momentDocs = storySnap.data.documents;

                      final moments =
                          momentDocs.map((doc) => Moment.fromDoc(doc)).toList();

                      final story = Story(
                          startAt: 0,
                          lastLoaded: 0,
                          moments: moments,
                          isFinished: false);

                      final userStory =
                          UserStory(story, Repo.currentProfile.user);

                      return ProfileHeader(
                        onAvatarPressed: () => momentDocs.isNotEmpty
                            ? Navigator.of(context, rootNavigator: true).push(
                                StoryPageView.route(0, [userStory],
                                    bgWidget: null))
                            : Navigator.of(context, rootNavigator: true)
                                .push(EditorPage.route()),
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
                                            profile: profile,
                                          )));

                          if (updatedProfile != null)

                            ///Dont trigger if user cancel edit profile
                            setState(() {
                              Repo.currentProfile = updatedProfile;
                              profile = updatedProfile;
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
                  return SizedBox(child: CircularProgressIndicator());
                final docs = snapshot.data.documents;
                var posts = docs.map((doc) => Post.fromDoc(doc)).toList();
                posts.removeWhere((p) => p == null);

                return posts.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  LineIcons.group,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                              Text(
                                'Create your first post',
                                style: TextStyles.large600Display.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(height: 20),
                              RaisedButton.icon(
                                color: Colors.blueAccent,
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .push(EditorPage.route()),
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Create Post',
                                  style: TextStyles.W500Text15.copyWith(
                                      color: Colors.white),
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