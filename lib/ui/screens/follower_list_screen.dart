import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_list_extended.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';

class FollowerListScreen extends StatefulWidget {
  final User user;
  final int initialTab;

  const FollowerListScreen({Key key, @required this.user, this.initialTab})
      : super(key: key);

  static Route route(User user, int initialTab) => MaterialPageRoute(
      builder: (context) => FollowerListScreen(
            user: user,
            initialTab: initialTab,
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
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          title: FlatButton(
            onPressed: () {},
            child: Text(
              widget.user.username,
              style: TextStyles.w600Text.copyWith(fontSize: 17),
            ),
          ),
        ),
        body: DefaultTabController(
          initialIndex: widget.initialTab,
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
                  Tab(text: 'Followers'),
                  Tab(text: 'Followings'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    FollowerTabView(uid: widget.user.uid, isFollowers: true),
                    FollowerTabView(uid: widget.user.uid, isFollowers: false),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class FollowerTabView extends StatefulWidget {
  final String uid;
  final bool isFollowers;

  const FollowerTabView({Key key, this.uid, this.isFollowers})
      : super(key: key);

  @override
  _FollowerTabViewState createState() => _FollowerTabViewState();
}

class _FollowerTabViewState extends State<FollowerTabView> {
  List<User> users;

  @override
  void initState() {
    _initUsers();
    super.initState();
  }

  void _initUsers() async {
    final results = widget.isFollowers
        ? await Repo.getFollowersOfUser(widget.uid)
        : await Repo.getFollowingsOfUser(widget.uid);

    setState(() {
      users = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshListView(
      onRefresh: () {},
      onLoadMore: () {},
      children: <Widget>[
        users == null
            ? EmptyIndicator('Loading...')
            : users.isEmpty
                ? EmptyIndicator('No users')
                : AvatarListExtended(
                    users: users,
                  ),
      ],
    );
  }
}
