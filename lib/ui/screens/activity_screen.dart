import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/activity.dart';
import 'package:nutes/core/models/follow_request.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/follow_request_screen.dart';
import 'package:nutes/ui/screens/post_detail_page.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/timeAgo.dart';

class ActivityScreen extends StatelessWidget {
  final List<FollowRequest> followRequests;

  const ActivityScreen({Key key, this.followRequests}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: DefaultTabController(
            initialIndex: 1,
            length: 2,
            child: Column(
              children: <Widget>[
                TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  labelStyle:
                      TextStyles.W500Text15.copyWith(color: Colors.black),
                  unselectedLabelStyle:
                      TextStyles.w300Text.copyWith(color: Colors.grey[300]),
                  tabs: [
                    Tab(text: 'Following'),
                    Tab(text: 'You'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      FollowingsActivityScreen(),
                      SelfActivityView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FollowingsActivityScreen extends StatefulWidget {
  @override
  _FollowingsActivityScreenState createState() =>
      _FollowingsActivityScreenState();
}

class _FollowingsActivityScreenState extends State<FollowingsActivityScreen> {
  List<User> followings = [];
  List<Activity> activities = [];

  @override
  void initState() {
    _getMyFollowings();
    super.initState();
  }

  _getMyFollowings() async {
    final result = await Repo.getMyUserFollowings(Repo.currentProfile.uid);
    setState(() {
      followings = result;
    });
    _getActivity();
  }

  _getActivity() async {
    var result = await Repo.getFollowingsActivity(followings);
    result.removeWhere((r) => r.owner == null);
    setState(() {
      activities = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshListView(
      onRefresh: () => _getActivity(),
      children: <Widget>[
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final user = activity.owner;
              final postUrl = activity.postUrl;
              final date = activity.timestamp;
              return ActivityListItem(activity: activity);
            }),
      ],
    );
  }
}

class SelfActivityView extends StatefulWidget {
  @override
  _SelfActivityViewState createState() => _SelfActivityViewState();
}

class _SelfActivityViewState extends State<SelfActivityView> {
  String uid = Auth.instance.profile.uid;

  Stream<QuerySnapshot> stream;

  @override
  void initState() {
    stream = Firestore.instance
        .collection('users')
        .document(uid)
        .collection('follow_requests')
        .snapshots();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return ListTile(
                    title: Text('Loading...'),
                  );
                return snapshot.data.documents.length > 0
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => FollowRequestScreen()),
                        ),
                        child: AvatarListItem(
                          avatar: AvatarImage(
                            url: Repo.currentProfile.user.photoUrl,
                            spacing: 0,
                          ),
                          title: 'Follow Requests',
                          subtitle: 'Accept or ignore requests',
                          trailingWidget: Icon(Icons.chevron_right),
                        ),
                      )
                    : ListTile(
                        title: Text('no follow requests'),
                      );
              }),
        ],
      ),
    );
  }
}

class ActivityListItem extends StatelessWidget {
  final Activity activity;

  const ActivityListItem({Key key, this.activity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AvatarListItem(
            avatar: AvatarImage(
              url: activity.owner.photoUrl,
            ),
            richTitle: TextSpan(children: [
              TextSpan(
                  text: activity.owner.username,
                  style: TextStyles.defaultText
                      .copyWith(fontWeight: FontWeight.w500)),
              TextSpan(
                  text: ' liked a post ${activity.postId}. ',
                  style: TextStyles.defaultText
                      .copyWith(fontWeight: FontWeight.w300)),
              TextSpan(
                  text: TimeAgo.formatShort(activity.timestamp.toDate()),
                  style: TextStyles.defaultText.copyWith(
                      fontWeight: FontWeight.w500, color: Colors.grey)),
            ])
//      title: '${activity.owner.username} liked a post',
            ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    PostDetailScreen.route(
                        Post(id: activity.postId, owner: activity.owner))),
                child: Container(
                  color: Colors.grey[100],
                  height: 110,
                  width: 110,
                  child: activity.metadata == null
                      ? CachedNetworkImage(
                          imageUrl: activity.postUrl,
                          fit: BoxFit.cover,
                        )
                      : Text('shout'),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
