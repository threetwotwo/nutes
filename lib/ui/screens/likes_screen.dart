import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_extended.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'package:nutes/ui/shared/search_bar.dart';
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
      appBar: BaseAppBar(
        title: Text(
          'Likes',
          style: TextStyles.W500Text15,
        ),
      ),
      body: SafeArea(
        child: AvatarListExtended(
          users: users,
        ),
      ),
    );
  }

  Future<void> _getUserLikes() async {
    final result = await Repo.getPostUserLikes(widget.post);
    final myFollowRequests = await Repo.getMyFollowRequests();

    setState(() {
      users = result;
      users = users
          .map((u) =>
              u.copyWith(hasRequestedFollow: myFollowRequests.contains(u.uid)))
          .toList();
    });
  }
}
