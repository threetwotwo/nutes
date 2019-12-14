import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/comment_overlay.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/core/models/post.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final Post post;

  static Route route(Post post) =>
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post));

  const PostDetailScreen({Key key, @required this.post, this.postId})
      : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool showCommentTextField = false;
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(),
      body: SafeArea(
          child: DismissView(
        child: CommentOverlay(
          onSend: (val) {},
          showTextField: showCommentTextField,
          controller: commentController,
          focusNode: commentFocusNode,
          onScroll: () {
            setState(() {
              showCommentTextField = false;
            });
          },
          child: SingleChildScrollView(
            child: PostListView(
              posts: [widget.post],
              onAddComment: (postId) {
                print('add comment for post $postId');

                setState(() {
                  showCommentTextField = true;
                });
                FocusScope.of(context).requestFocus(commentFocusNode);
              },
            ),
          ),
        ),
      )),
    );
  }
}
