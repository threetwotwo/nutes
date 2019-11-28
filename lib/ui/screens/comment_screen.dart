import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/comment_text_field.dart';
import 'package:nutes/ui/shared/refresh_list_view.dart';
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
  Offset offset;

  bool showSearchScreen = false;

  @override
  void initState() {
    _getComments();
    commentController.addListener(() {
      ///TODO: regex for mentions
      if (commentController.text
          .contains(RegExp(r"(?<!@)\B@[a-z\._0-9]*?$", caseSensitive: false)))
        setState(() {
          showSearchScreen = true;
        });
      else
        setState(() {
          showSearchScreen = false;
        });
    });
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
          child: Stack(
        children: <Widget>[
          NotificationListener(
            onNotification: (t) {
              if (t is UserScrollNotification) {
                FocusScope.of(context).requestFocus(FocusNode());
              }
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
          ),
          if (showSearchScreen)
            Positioned.fill(
                child: Container(
              color: Colors.pink,
            )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (replyingTo != null)
                  Container(
                    color: Colors.grey[200],
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Replying to ${replyingTo.owner.username}',
                              style: TextStyle(color: Colors.grey),
                            )),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              replyingTo = null;
                              commentController.clear();
                            });
                          },
                          icon: Icon(
                            LineIcons.close,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                EmojiPicker(
                  onEmojiSelected: (val, _) => commentController.text =
                      commentController.text + val.emoji,
                  rows: 1,
                  recommendKeywords: [
                    'Crying Face',
                    'Face With Tears of Joy',
                    'Clapping Hands',
                    'Raising Hands',
                    'Winking Face With Tongue',
                    'Face With Open Mouth',
                    'Smiling Face With Heart-Eyes',
                    'OK Hand',
                    'Victory Hand',
                    'Folded Hands',
                    'Love-You Gesture',
                    'Middle Finger',
                    'Thumbs Up',
                    'Thumbs Down',
                    'Red Heart',
                  ],
                  numRecommended: 60,
                  columns: 8,
                  bgColor: Colors.white,
                  indicatorColor: Colors.grey,
//                        buttonMode: ButtonMode.MATERIAL,
                ),
                CommentTextField(
                  controller: commentController,
                  focusNode: commentNode,
                  hint: 'Add comment as ${auth.profile.user.username}...',
                  onSendPressed: (val) {
                    final text = commentController.text;

                    final comment = Repo.newComment(
                        text: text,
                        postId: widget.postId,
                        parentComment: replyingTo);

//                    final comment = Comment(
//                      parentId: replyingTo?.id ?? null,
//                      timestamp: Timestamp.now(),
//                      text: text,
//                      owner: auth.profile.user,
//                    );

                    ///TODO: find where to insert new comment

                    int insertIndex;

                    final itemHeight = 70.0;

                    insertIndex = comment.parentId == null
                        ? 0
                        : comments.indexWhere((c) => c.id == comment.parentId) +
                            1;

                    if (mounted) {
                      setState(() {
                        comments.insert(insertIndex, comment);

                        replyingTo = null;
                      });

                      listController.animateTo(insertIndex * itemHeight,
                          curve: Curves.easeInOut,
                          duration: Duration(milliseconds: 300));
                    }
                    commentController.clear();

//                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
