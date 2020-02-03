import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/activity.dart';
import 'package:nutes/core/models/follow_request.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/follow_request_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/activity_list_item.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatelessWidget {
  final List<FollowRequest> followRequests;

  const ActivityScreen({
    Key key,
    this.followRequests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  labelStyle: TextStyles.w600Text.copyWith(color: Colors.black),
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
  List<Activity> activities = [];
  List<ActivityBundle> bundles = [];

//  final auth = Repo.auth;

  bool isLoading = false;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _getActivities();
    super.initState();
  }

  _getActivities() async {
    setState(() {
      isLoading = true;
    });
    var result = await Repo.getMyFollowingsActivity();
    setState(() {
      isLoading = false;
      activities = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingIndicator()
        : activities.isEmpty
            ? EmptyIndicator('No recent activity')
            : RefreshListView(
                onRefresh: () => _getActivities(),
                children: <Widget>[
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];

//                        final user = activity.postOwner;
//                        final postUrl = activity.postUrl;
//                        final date = activity.timestamp;
                        return ActivityListItem(
                          activity: activity,
                        );
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
  List<Activity> _activities = [];

  @override
  void initState() {
    _getActivities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfile>(context);

    return RefreshListView(
      onRefresh: _getActivities,
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('users')
                .document(profile.uid)
                .collection('follow_requests')
                .snapshots(),
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
                        trailingFlexFactor: 1,
                        avatar: AvatarImage(
                          url: profile.user.urls.small,
//                          spacing: 0,
                          padding: 8,
                        ),
                        title: 'Follow Requests',
                        subtitle: 'Accept or ignore requests',
                        trailingWidget: Icon(Icons.chevron_right),
                      ),
                    )
                  : SizedBox();
            }),
        _activities.isEmpty
            ? EmptyIndicator('No recent activity')
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final act = _activities[index];

                  return ActivityListItem(
                    activity: act,
                  );
                }),
      ],
    );
  }

  Future<void> _getActivities() async {
    final result = await Repo.getMyActivity();

    setState(() {
      _activities = result;
    });
  }
}

//class ActivityBundleListItem extends StatelessWidget {
//  final ActivityBundle bundle;
//
//  const ActivityBundleListItem({Key key, this.bundle}) : super(key: key);
//  @override
//  Widget build(BuildContext context) {
//    final length = bundle.activities.length;
//    return Column(
//      children: <Widget>[
//        AvatarListItem(
//            avatar: AvatarImage(
//              url: bundle.owner.urls.small,
//            ),
//            richTitle: TextSpan(children: [
//              TextSpan(
//                  text: bundle.owner.username,
//                  style: TextStyles.defaultText
//                      .copyWith(fontWeight: FontWeight.w500)),
//              TextSpan(
//                  text:
//                      ' liked ${length > 1 ? length : 'a'} post${length > 1 ? 's' : ''}. ',
//                  style: TextStyles.w300Text),
//              TextSpan(
//                  text: TimeAgo.formatShort(bundle.timestamp.toDate()),
//                  style: TextStyles.w300Text.copyWith(color: Colors.grey)),
//            ])
////      title: '${activity.owner.username} liked a post',
//            ),
//        Container(
//          height: 110,
//          child: ListView.builder(
////              shrinkWrap: true,
//              itemCount: bundle.activities.length,
//              scrollDirection: Axis.horizontal,
//              itemBuilder: (context, idx) {
//                final activity = bundle.activities[idx];
//
//                return Padding(
//                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    children: <Widget>[
//                      GestureDetector(
//                        onTap: () {
//                          return Navigator.push(
//                            context,
//                            PostDetailScreen.route(null,
//                                postId: activity.postId,
//                                ownerId: activity.postOwner.uid),
//                          );
//                        },
//                        child: Container(
//                          decoration: BoxDecoration(
//                            color: Colors.grey[100],
//                            border: Border.all(color: Colors.grey[200]),
//                          ),
//                          height: 110,
//                          width: 110,
//                          child: activity.post.type == PostType.text
//                              ? CachedNetworkImage(
//                                  imageUrl: activity.postUrl,
//                                  fit: BoxFit.cover,
//                                )
//                              : ShoutGridItem(
//                                  metadata: activity.metadata,
//                                  avatarSize: 24,
//                                  fontSize: 10,
//                                ),
//                        ),
//                      )
//                    ],
//                  ),
//                );
//              }),
//        )
//      ],
//    );
//  }
//}
