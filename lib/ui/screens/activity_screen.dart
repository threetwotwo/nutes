import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/activity.dart';
import 'package:nutes/core/models/follow_request.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/follow_request_screen.dart';
import 'package:nutes/ui/screens/post_detail_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/shout_grid_item.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/timeAgo.dart';
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
  void initState() {
    _getActivity();
    super.initState();
  }

  _getActivity() async {
    setState(() {
      isLoading = true;
    });
    var result = await Repo.getMyFollowingsActivity();
//    result.removeWhere((r) => r.activityType == null);
    setState(() {
      isLoading = false;
      activities = result;
    });

    final postLikes = result
        .where((ac) => ac.activityType == ActivityType.post_like)
        .toList();

    if (postLikes.isEmpty) return;

    final likesBundle = ActivityBundle.from(postLikes, ActivityType.post_like);

    bundles.add(likesBundle);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingIndicator()
        : activities.isEmpty
            ? EmptyIndicator('No followings activity')
            : RefreshListView(
                onRefresh: () => _getActivity(),
                children: <Widget>[
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: bundles.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        final user = activity.postOwner;
                        final postUrl = activity.postUrl;
                        final date = activity.timestamp;
                        return ActivityListItem(bundle: bundles[index]);
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
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfile>(context);

    return ListView(
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
                        avatar: AvatarImage(
                          url: profile.user.urls.small,
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
    );
  }
}

class ActivityListItem extends StatelessWidget {
  final ActivityBundle bundle;

  const ActivityListItem({Key key, this.bundle}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final length = bundle.activities.length;
    return Column(
      children: <Widget>[
        AvatarListItem(
            avatar: AvatarImage(
              url: bundle.owner.urls.small,
            ),
            richTitle: TextSpan(children: [
              TextSpan(
                  text: bundle.owner.username,
                  style: TextStyles.defaultText
                      .copyWith(fontWeight: FontWeight.w500)),
              TextSpan(
                  text:
                      ' liked ${length > 1 ? length : 'a'} post${length > 1 ? 's' : ''}. ',
                  style: TextStyles.defaultText
                      .copyWith(fontWeight: FontWeight.w300)),
              TextSpan(
                  text: TimeAgo.formatShort(bundle.timestamp.toDate()),
                  style: TextStyles.defaultText.copyWith(
                      fontWeight: FontWeight.w500, color: Colors.grey)),
            ])
//      title: '${activity.owner.username} liked a post',
            ),
        Container(
          height: 110,
          child: ListView.builder(
//              shrinkWrap: true,
              itemCount: bundle.activities.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, idx) {
                final activity = bundle.activities[idx];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          return Navigator.push(
                            context,
                            PostDetailScreen.route(null,
                                postId: activity.postId,
                                ownerId: activity.postOwner.uid),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[200]),
                          ),
                          height: 110,
                          width: 110,
                          child: activity.postType == PostType.text
                              ? CachedNetworkImage(
                                  imageUrl: activity.postUrl,
                                  fit: BoxFit.cover,
                                )
                              : ShoutGridItem(
                                  metadata: activity.metadata,
                                  avatarSize: 24,
                                  fontSize: 10,
                                ),
                        ),
                      )
                    ],
                  ),
                );
              }),
        )
      ],
    );
  }
}
