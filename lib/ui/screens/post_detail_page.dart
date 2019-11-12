import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/core/models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  final Post post;

  static Route route(Post post) =>
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post));

  const PostDetailScreen({Key key, @required this.post, this.postId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: SafeArea(
          child: DismissView(
        onDismiss: () => Navigator.pop(context),
        child: SingleChildScrollView(
          child: PostListItem(post: post),
        ),
      )),
    );
  }
}
