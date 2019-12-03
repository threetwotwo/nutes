import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/my_profile_screen.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';

class SearchResultsScreen extends StatefulWidget {
  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              labelStyle: TextStyles.w600Text,
              unselectedLabelStyle:
                  TextStyles.w300Text.copyWith(color: Colors.grey[300]),
              tabs: [
                Tab(text: 'Accounts'),
                Tab(text: 'Hashtags'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();

                      final docs = snapshot.data.documents;

                      return StreamBuilder<DocumentSnapshot>(
                          stream: Repo.myFollowingListStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return SizedBox();
                            final List followingIds = snapshot.data.data == null
                                ? []
                                : snapshot.data.data['uids'] ?? [];

                            return RefreshListView(
//                              onRefresh: () {},
//                              onLoadMore: () {},
                              children: <Widget>[
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: docs.length,
                                    itemBuilder: (context, index) {
                                      final user = User.fromMap(
                                          docs[index].data,
                                          uid: docs[index].documentID);

                                      final isFollowingText =
                                          followingIds.contains(user.uid)
                                              ? user.displayName.isEmpty
                                                  ? 'Follo'
                                                      'wing'
                                                  : ' • Following'
                                              : '';
                                      return AvatarListItem(
                                        avatar: AvatarImage(
                                          url: user.photoUrl,
                                          spacing: 1.6,
//                                      showStoryIndicator: true,
                                          padding: 8,
                                          addStory: false,
                                        ),
                                        title: user.username,
                                        subtitle:
                                            '${user.displayName}$isFollowingText',
//                                    trailingWidget: Padding(
//                                      padding: const EdgeInsets.all(8.0),
//                                      child: Text(
//                                        followingIds.contains(user.uid)
//                                            ? 'Following'
//                                            : '',
//                                        style: TextStyle(color: Colors.grey),
//                                      ),
//                                    ),
                                        onAvatarTapped:
                                            _navigateToProfile(context, user),
                                        onBodyTapped:
                                            _navigateToProfile(context, user),
                                      );
                                    }),
                              ],
                            );
                          });
                    },
                  ),
                  Icon(Icons.directions_bike),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Function _navigateToProfile(BuildContext context, User user) {
    return () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(uid: user.uid),
          ),
        );
  }
}
