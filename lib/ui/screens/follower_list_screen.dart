import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_extended.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';

class FollowerListScreen extends StatefulWidget {
  final User user;

  const FollowerListScreen({Key key, @required this.user}) : super(key: key);

  static Route route(User user) => MaterialPageRoute(
      builder: (context) => FollowerListScreen(
            user: user,
          ));

  @override
  _FollowerListScreenState createState() => _FollowerListScreenState();
}

class _FollowerListScreenState extends State<FollowerListScreen> {
  List<User> followers = [];

  bool isLoading = false;

  @override
  void initState() {
    _getFollowers();
    super.initState();
  }

  Future<void> _getFollowers() async {
    final result = await Repo.getFollowersOfUser(widget.user.uid);
    setState(() {
      followers = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: FlatButton(
          onPressed: () {},
          child: Text(widget.user.username),
        ),
      ),
      body: DismissView(
        onDismiss: () => Navigator.pop(context),
        child: Container(
          child: RefreshListView(
            children: <Widget>[
              AvatarListExtended(
                users: followers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
