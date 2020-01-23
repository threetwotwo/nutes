import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';

class BlockedAccountsScreen extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => BlockedAccountsScreen());

  @override
  _BlockedAccountsScreenState createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  bool isLoading = false;

  List<User> users = [];

  _getUsers() async {
    setState(() {
      isLoading = true;
    });
    final result = await Repo.getBlockedUsers();
    setState(() {
      isLoading = false;
      users = result;
    });
  }

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: Text(
          'Blocked',
          style: TextStyles.header,
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? LoadingIndicator()
            : users.isEmpty
                ? EmptyIndicator('No users found')
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context, ProfileScreen.route(user.uid));
                        },
                        child: AvatarListItem(
                          avatar: AvatarImage(
                            url: user.urls.small,
                          ),
                          title: user.username,
                          subtitle: user.displayName,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
