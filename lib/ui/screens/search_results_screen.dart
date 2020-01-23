import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/widgets/recent_search_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final TextEditingController controller;

  const SearchResultsScreen({Key key, this.controller}) : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with AutomaticKeepAliveClientMixin<SearchResultsScreen> {
  List<User> users = [];

  ///List of users who have blocked me
  List blockedBy = [];

  bool isSearching = false;

  bool isEmpty = true;

  String searchText;

  _getBlockedBy() async {
    final result = await Repo.getBlockedBy();

    if (mounted)
      setState(() {
        blockedBy = result;
      });

    print('blocked by: $result');
  }

  _search(String text) async {
    if (text.isEmpty)
      return;
    else {
      if (mounted)
        setState(() {
          isSearching = true;
          searchText = text;
        });

      final result = await Repo.searchUsers(text)
        ..removeWhere((user) => blockedBy.contains(user.uid));

      if (mounted)
        setState(() {
          isSearching = false;
          users = result;
        });
    }
  }

  @override
  void initState() {
    _getBlockedBy();

    widget.controller.addListener(() {
      if (widget.controller.text != searchText) _search(widget.controller.text);

      if (mounted)
        setState(() {
          isEmpty = widget.controller.text.isEmpty;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      child: StreamBuilder<DocumentSnapshot>(
          stream: Repo.myFollowingListStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();
            final List followingIds = snapshot.data.data == null
                ? []
                : snapshot.data.data['uids'] ?? [];

            return isSearching
                ? Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CupertinoActivityIndicator(),
                        SizedBox(width: 8),
                        Text(
                          'Searching for '
                          '\"$searchText\"',
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ))
                : isEmpty
                    ? RecentSearchScreen()
                    : users.isEmpty
                        ? EmptyIndicator('No users found')
                        : RefreshListView(
                            children: <Widget>[
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    final user = users[index];

                                    final isFollowingText =
                                        followingIds.contains(user.uid)
                                            ? user.displayName.isEmpty
                                                ? 'Follo'
                                                    'wing'
                                                : ' • Following'
                                            : '';
                                    return AvatarListItem(
                                      avatar: AvatarImage(
                                        url: user.urls.small,
                                        spacing: 1.6,
                                        padding: 8,
                                        addStory: false,
                                      ),
                                      title: user.username,
                                      subtitle:
                                          '${user.displayName}$isFollowingText',
                                      onAvatarTapped: () =>
                                          _navigateToProfile(context, user),
                                      onBodyTapped: () =>
                                          _navigateToProfile(context, user),
                                    );
                                  }),
                            ],
                          );
          }),
    );
  }

  Future _navigateToProfile(BuildContext context, User user) {
    Repo.createRecentSearch(user);
    return Navigator.of(context).push(ProfileScreen.route(user.uid));
  }

  @override
  bool get wantKeepAlive => true;
}
