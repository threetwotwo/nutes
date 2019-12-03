//import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/comment_overlay.dart';
import 'package:nutes/ui/shared/comment_text_field.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
import 'package:nutes/ui/shared/search_overlay.dart';
import 'package:nutes/ui/widgets/comment_list_item.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({Key key, this.postId}) : super(key: key);

  static Route route(String postId) => MaterialPageRoute(
      builder: (context) => CommentScreen(
            postId: postId,
          ));

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<Comment> comments = [];
  bool loading = false;

  final auth = Auth.instance;

  ///currently replying to a comment
  Comment replyingTo;
  final commentController = TextEditingController();
  final commentNode = FocusNode();
  final listController = ScrollController();

  final GlobalKey globalKey = GlobalKey();

//  bool showSearchScreen = false;

  @override
  void initState() {
    _getComments();

    final regex = RegExp(r"(?<!@)\B@[a-z\._0-9]*?$", caseSensitive: false);

//    commentController.addListener(() {
//      if (commentController.text.contains(regex))
//        setState(() {
//          showSearchScreen = true;
//        });
//      else
//        setState(() {
//          showSearchScreen = false;
//        });
//    });
    super.initState();
  }

  _getComments() async {
    setState(() {
      loading = true;
    });
    final result = await Repo.getComments(widget.postId);

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
          child: RefreshListView(
            onRefresh: () => _getComments(),
            onLoadMore: () {},
            children: <Widget>[
              ListView.separated(
                  controller: listController,
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
                          setState(() {
                            replyingTo = comment;
                            commentController.text =
                                '@${comment.owner.username} ';
                          });

                          FocusScope.of(context).requestFocus(commentNode);
                        },
                      )),
              SizedBox(height: 16),
              Divider(),

              ///Spacer
              Container(
                height: 200,
              ),
            ],
          ),
          onSend: (text) {
            final comment = Repo.newComment(
                text: text, postId: widget.postId, parentComment: replyingTo);

            print(comment.parentId);

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

              listController.animateTo(insertIndex * itemHeight,
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 300));
            }
          },
        ),
      ),
    );
  }
}
