import 'package:flutter/material.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/comment_overlay.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/post_list.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String ownerId;
  final Post post;

  static Route route(Post post, {String postId, String ownerId}) =>
      MaterialPageRoute(
          builder: (context) => PostDetailScreen(
                post: post,
                postId: postId,
                ownerId: ownerId,
              ));

  const PostDetailScreen(
      {Key key, @required this.post, this.postId, this.ownerId})
      : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool showCommentTextField = false;
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

  bool isLoading = false;

  Post post;

  bool isDoodling = false;

  Future<void> _getPost() async {
    setState(() {
      isLoading = true;
    });
    final result = await Repo.getPostComplete(widget.postId, widget.ownerId);

    setState(() {
      isLoading = false;
      post = result;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    if (widget.post != null) {
      post = widget.post;
    } else {
      _getPost();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: Column(
          children: <Widget>[
            Text(
              widget.post.owner.username.toUpperCase(),
              style: TextStyles.defaultText.copyWith(color: Colors.grey),
            ),
            Text(
              'Post',
              style: TextStyles.header,
            ),
          ],
        ),
      ),
      body: SafeArea(
          child: DismissView(
        enabled: !isDoodling,
        child: isLoading
            ? LoadingIndicator()
            : CommentOverlay(
                onSend: (val) {},
                showTextField: showCommentTextField,
                controller: commentController,
                focusNode: commentFocusNode,
                onScroll: () {
                  setState(() {
                    showCommentTextField = false;
                  });
                },
                child: RefreshListView(
                  children: <Widget>[
                    PostListView(
                      posts: [post],
                      onAddComment: (postId) {
                        setState(() {
                          showCommentTextField = true;
                        });
                        FocusScope.of(context).requestFocus(commentFocusNode);
                      },
                      onDoodleStart: () {
                        setState(() {
                          isDoodling = true;
                        });
                      },
                      onDoodleEnd: () {
                        setState(() {
                          isDoodling = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
      )),
    );
  }
}
