import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/comment_overlay.dart';
import 'package:nutes/ui/shared/dismiss_view.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/styles.dart';
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

  List<Comment> newComments = [];

  DocumentSnapshot startAfter;

  String _isLoadingMoreReplies;

  @override
  void initState() {
    _getInitialComments();

    super.initState();
  }

  Future<void> _getInitialComments() async {
    setState(() {
      loading = true;
      startAfter = null;
    });
    final result = await Repo.getComments(widget.post.id, startAfter);

    setState(() {
      loading = false;
      comments = result.comments;
      startAfter = result.startAfter;
    });
  }

  Future<void> _getMoreReplies(String parentId, DocumentSnapshot snap) async {
    setState(() {
      _isLoadingMoreReplies = parentId;
    });
    final result = await Repo.getMoreReplies(widget.post.id, parentId, snap);
    print(result);
    final insertIndex = comments.indexWhere((c) => c.id == parentId) + 1;

    print('INSERT REPLIES AT $insertIndex');
    setState(() {
      comments.insertAll(insertIndex, result);
      _isLoadingMoreReplies = null;
    });
  }

  Future<void> _getMoreComments() async {
    if (comments.length < 8) return;

    final result = await Repo.getComments(widget.post.id, startAfter);

    setState(() {
      loading = false;
      comments += result.comments;
      startAfter = result.startAfter;
    });
  }

  int _numberOfRepliesShownForComment(String commentId) {
    return comments.where((c) => c.parentId == commentId).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: Text(
          'Comments',
          style: TextStyles.header,
        ),
        result: newComments,
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
                    onRefresh: _getInitialComments,
                    onLoadMore: _getMoreComments,
                    children: <Widget>[
                      ///Caption
                      if (widget.post.caption.isNotEmpty) ...[
                        CommentListItem(
                          isCaption: true,
                          comment: Comment(
                              text: widget.post.caption,
                              timestamp: widget.post.timestamp,
                              owner: widget.post.owner),
                        ),
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
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return StreamBuilder<DocumentSnapshot>(
                                    stream: Repo.commentLikeStream(
                                        widget.post.id, comment.id),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return SizedBox();

                                      final didLike = snapshot.data.exists;
                                      return CommentListItem(
                                        isLoadingMore:
                                            _isLoadingMoreReplies == comment.id,
                                        didLike: didLike,
                                        onDelete: () {
                                          print(
                                              'delete comment ${comment.text}');
                                          Repo.deleteComment(
                                              widget.post.id, comment.id);
                                          setState(() {
                                            comments.remove(comment);
                                          });
                                        },
                                        onLike: () {
                                          didLike
                                              ? Repo.unlikeComment(
                                                  widget.post.id, comment)
                                              : Repo.likeComment(
                                                  widget.post, comment);
                                          setState(() {
                                            comments[index] = comment.copyWith(
                                                likeCount:
                                                    comment.stats.likeCount +
                                                        (didLike ? -1 : 1));
                                          });
                                        },
                                        comment: comment,
                                        repliesVisibleCount:
                                            _numberOfRepliesShownForComment(
                                                comment.id),
                                        onReply: (c) {
                                          print(
                                              'reply to ${c.text} with id: ${c.id}');

                                          ///TODO: jump to comment
//                                    scrollController.jumpTo(100);
                                          setState(() {
                                            replyingTo = c;
                                            commentController.text =
                                                '@${c.owner.username} ';
                                          });

                                          FocusScope.of(context)
                                              .requestFocus(commentNode);
                                        },
                                        onMoreReplies: () {
                                          Comment startAfter;

                                          if (comment.parentId == 'root')
                                            startAfter = comments[index + 1];
                                          else {
                                            final index = comments.indexWhere(
                                                (c) => c.parentId == c.id);

                                            startAfter = index > 0
                                                ? comments[index]
                                                : null;
                                          }

                                          print(startAfter?.id);
//                                          final r = comments
//                                              .lastIndexWhere((c) => c.id);

//                                          print(
//                                              'parent comment: ${comment.text} next reply in comment screen is ${comments[index + 1].text}');

                                          _getMoreReplies(
                                              comment.id, startAfter?.doc);
                                        },
                                      );
                                    });
                              }),
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
                text: text.trim(),
                postId: widget.post.id,
                parentComment: replyingTo,
              );

//              print(comment.toMap());

              Repo.uploadComment(post: widget.post, comment: comment);

              int insertIndex;

              final itemHeight = 70.0;

              ///Insert at a top if a root comment
              insertIndex = comment.parentId == null
                  ? 0
                  : comments.indexWhere((c) => c.id == comment.parentId) + 1;

              if (mounted) {
                setState(() {
                  comments.insert(insertIndex, comment);
                  newComments.add(comment);

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
