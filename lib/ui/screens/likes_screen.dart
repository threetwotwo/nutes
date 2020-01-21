import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_list_extended.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({
    Key key,
    @required this.post,
  }) : super(key: key);

  static Route route(Post post) {
    return MaterialPageRoute(builder: (context) => LikeScreen(post: post));
  }

  final Post post;

  @override
  _LikeScreenState createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  List<User> users = [];

  bool isLoading = false;

  ///Helper array to update follow button to say 'requested'
//  List<bool> privateAccountRequests = [];
  final textEditingController = TextEditingController();

  @override
  void initState() {
    _getUserLikes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: Text(
          'Likes',
          style: TextStyles.w600Text,
        ),
      ),
      body: SafeArea(
        child: DismissView(
          child: isLoading
              ? LoadingIndicator()
              : users.isEmpty
                  ? EmptyIndicator('No one has liked this post')
                  : AvatarListExtended(
                      users: users,
                    ),
        ),
      ),
    );
  }

  Future<void> _getUserLikes() async {
    setState(() {
      isLoading = true;
    });
    final result = await Repo.getPostUserLikes(widget.post);
//    final myFollowRequests = await Repo.getMyFollowRequests();

    setState(() {
      users = result;
//      users = users
//          .map((u) =>
//              u.copyWith(hasRequestedFollow: myFollowRequests.contains(u.uid)))
//          .toList();
      isLoading = false;
    });
  }
}
