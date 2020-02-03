import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_list_extended.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';

class SeenByScreen extends StatefulWidget {
  final String momentId;
  final String ownerId;
  final UserCursor userCursor;

  const SeenByScreen({
    Key key,
    @required this.momentId,
    @required this.ownerId,
    @required this.userCursor,
  }) : super(key: key);

  static Route route(
          {String momentId, String ownerId, UserCursor userCursor}) =>
      MaterialPageRoute(
          builder: (_) => SeenByScreen(
                momentId: momentId,
                ownerId: ownerId,
                userCursor: userCursor,
              ));

  @override
  _SeenByScreenState createState() => _SeenByScreenState();
}

class _SeenByScreenState extends State<SeenByScreen> {
  List<User> users = [];
  UserCursor userCursor;

  @override
  void initState() {
    users.addAll(widget.userCursor?.users ?? []);

    _initUsers();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: Text(
          'Seen by',
          style: TextStyles.header,
        ),
      ),
      body: RefreshListView(
        onLoadMore: _getMoreUsers,
        children: <Widget>[
          AvatarListExtended(
            users: users,
          ),
        ],
      ),
    );
  }

  Future<void> _initUsers() async {
    final result = await Repo.getMoreMomentSeenBy(
        ownerId: widget.ownerId,
        momentId: widget.momentId,
        startAfter: widget.userCursor.startAfter);

    setState(() {
      users.addAll(result.users);
      userCursor = result;
    });
  }

  Future<void> _getMoreUsers() async {
    final result = await Repo.getMoreMomentSeenBy(
        ownerId: widget.ownerId,
        momentId: widget.momentId,
        startAfter: userCursor.startAfter);

    setState(() {
      users.addAll(result.users);
      userCursor = result;
    });
  }
}
