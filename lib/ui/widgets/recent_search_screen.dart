import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';

class RecentSearchScreen extends StatefulWidget {
  @override
  _RecentSearchScreenState createState() => _RecentSearchScreenState();
}

class _RecentSearchScreenState extends State<RecentSearchScreen> {
  List<User> users = [];

  bool isLoading = false;

  _getRecentSearches() async {
    setState(() {
      isLoading = true;
    });

    final result = await Repo.getRecentSearches();

    setState(() {
      isLoading = false;
      users = result;
    });
  }

  Future _navigate(String uid) {
    return Navigator.push(context, ProfileScreen.route(uid));
  }

  @override
  void initState() {
    _getRecentSearches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent',
                style: TextStyles.w600Text.copyWith(fontSize: 24),
              ),
            ),
            isLoading
                ? LoadingIndicator()
                : users.isEmpty
                    ? EmptyIndicator('No recent searches')
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (_, index) {
                          final user = users[index];
                          return AvatarListItem(
                            onAvatarTapped: () => _navigate(user.uid),
                            onBodyTapped: () => _navigate(user.uid),
                            avatar: AvatarImage(
                              url: user.urls.small,
                            ),
                            title: user.username,
                            subtitle: user.displayName,
                            trailingWidget: CancelButton(
                              color: Colors.grey,
                              onPressed: () {
                                setState(() {
                                  users.removeWhere((u) => u.uid == user.uid);
                                });
                                return Repo.deleteRecentSearch(user.uid);
                              },
                              size: 20,
                            ),
                          );
                        })
          ],
        ),
      ),
    );
  }
}
