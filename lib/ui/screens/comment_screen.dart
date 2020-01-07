import 'package:flutter/material.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/comment_overlay.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/widgets/comment_list_item.dart';

class CommentScreen extends StatefulWidget {
  final Post post;

  const CommentScreen({Key key, this.post}) : super(key: key);

  static Route route(Post post) => MaterialPageRoute(
      builder: (context) => CommentScreen(
            post: post,
          ));

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<Comment> comments = [];
  bool loading = false;

  final auth = Repo.auth;

  ///currently replying to a comment
  Comment replyingTo;
  final commentController = TextEditingController();
  final commentNode = FocusNode();
  final scrollController = ScrollController();

  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    _getComments();

    super.initState();
  }

  _getComments() async {
    setState(() {
      loading = true;
    });
    final result = await Repo.getComments(widget.post.id);

    setState(() {
      loading = false;
      comments = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: Text(
          'Comments',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: DismissView(
          child: CommentOverlay(
            showTextField: true,
            controller: commentController,
            replyingTo: replyingTo,
            focusNode: commentNode,
            onClear: () {
              print('on clear');
              setState(() {
                replyingTo = null;
              });

              return;
            },
            child: loading
                ? LoadingIndicator()
                : RefreshListView(
                    onRefresh: () => _getComments(),
                    onLoadMore: () {},
                    children: <Widget>[
                      ///Caption
                      if (widget.post.caption.isNotEmpty) ...[
                        CommentListItem(
                            isCaption: true,
                            comment: Comment(
                                text: widget.post.caption,
                                timestamp: widget.post.timestamp,
                                owner: widget.post.owner)),
                        Divider(),
                      ],
                      comments.isEmpty
                          ? EmptyIndicator('No comments')
                          : ListView.separated(
                              controller: scrollController,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) => Container(
                                    height: 10,
                                  ),
                              itemCount: comments.length,
                              itemBuilder: (context, index) => CommentListItem(
                                    comment: comments[index],
                                    onReply: (comment) {
                                      print('reply to ${comment.text}');

                                      ///TODO: jump to comment
//                                    scrollController.jumpTo(100);
                                      setState(() {
                                        replyingTo = comment;
                                        commentController.text =
                                            '@${comment.owner.username} ';
                                      });

                                      FocusScope.of(context)
                                          .requestFocus(commentNode);
                                    },
                                  )),
                      SizedBox(height: 16),

                      ///Spacer
                      Container(
//                color: Colors.grey[100],
                        height: 200,
                      ),
                    ],
                  ),
            onSend: (text) {
              final comment = Repo.createComment(
                  text: text,
                  postId: widget.post.id,
                  parentComment: replyingTo);

              Repo.uploadComment(postId: widget.post.id, comment: comment);

              int insertIndex;

              final itemHeight = 70.0;

              insertIndex = comment.parentId == null
                  ? 0
                  : comments.indexWhere((c) => c.id == comment.parentId) + 1;

              if (mounted) {
                setState(() {
                  comments.insert(insertIndex, comment);

                  replyingTo = null;
                });

                if (scrollController.hasClients)
                  scrollController.animateTo(insertIndex * itemHeight,
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 300));
              }
            },
          ),
        ),
      ),
    );
  }
}
