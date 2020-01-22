import 'package:flutter/material.dart';
import 'package:nutes/core/models/comment.dart';
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

  List<Post> posts = [];

  bool isDoodling = false;

  Future<void> _getPost() async {
    setState(() {
      isLoading = true;
    });
    final result = await Repo.getPostComplete(widget.postId ?? widget.post.id,
        widget.ownerId ?? widget.post.owner.uid);

    setState(() {
      isLoading = false;
      posts = [result];
    });

    if (posts.first.topComments == null) _getComments();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    if (widget.post != null) {
      posts = [widget.post];
      if (posts.first.topComments == null) _getComments();
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
        title: posts.isEmpty
            ? SizedBox()
            : Column(
                children: <Widget>[
                  Text(
                    posts.first.owner.username.toUpperCase(),
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
                onSend: (text) async {
                  print('on send $text');
                  final commentingTo = posts.first;
                  final comment = Repo.createComment(
                    text: text,
                    postId: commentingTo.id,
                  );

                  Repo.uploadComment(post: commentingTo, comment: comment);

                  final newPost = posts.first.copyWith(
                    topComments: posts.first.topComments + [comment],
                  );

                  setState(() {
                    posts = [];
                    showCommentTextField = false;
                  });

                  ///To fix bug where post list view wont refresh
                  await Future.delayed(Duration(milliseconds: 15));

                  setState(() {
                    posts = [newPost];
                  });
                },
                showTextField: showCommentTextField,
                controller: commentController,
                focusNode: commentFocusNode,
                onScroll: () {
                  setState(() {
                    showCommentTextField = false;
                  });
                },
                child: RefreshListView(
                  onRefresh: _getPost,
                  children: <Widget>[
                    PostListView(
                      posts: posts,
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

  void _getComments() async {
    final result = await Repo.getPostTopComments(posts.first.id, limit: 5);

    final newPost = posts.first.copyWith(
        topComments: posts.first.topComments ?? List<Comment>() + result);

    setState(() {
      posts = [];
    });

    ///To fix bug where post list view wont refresh
    await Future.delayed(Duration(milliseconds: 15));

    setState(() {
      posts = [newPost];
    });
  }
}
