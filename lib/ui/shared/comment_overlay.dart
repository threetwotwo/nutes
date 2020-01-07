import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/ui/shared/search_result_view.dart';
import 'package:nutes/ui/widgets/emoji_picker.dart';

import 'comment_text_field.dart';

class CommentOverlay extends StatefulWidget {
  final Widget child;
  final Function(String) onSend;
  final VoidCallback onClear;
  Comment replyingTo;

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showTextField;
  final Function onScroll;

  CommentOverlay({
    Key key,
    @required this.controller,
    @required this.focusNode,
    @required this.showTextField,
    @required this.onSend,
    this.child,
    this.onClear,
    this.replyingTo,
    this.onScroll,
  }) : super(key: key);
  @override
  _CommentOverlayState createState() => _CommentOverlayState();
}

class _CommentOverlayState extends State<CommentOverlay> {
  bool showSearchScreen = false;

//  final auth = Repo.auth;

  ///currently replying to this comment
  Comment replyingTo;

  final regex = RegExp(r"(?<!@)\B@[a-z\._0-9]*?$", caseSensitive: false);

  @override
  void initState() {
    replyingTo = widget.replyingTo;

    widget.controller.addListener(() {
      if (widget.controller.text.contains(regex))
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

  @override
  Widget build(BuildContext context) {
//    final profile = Provider.of<UserProfile>(context);

    return Stack(
      children: <Widget>[
        NotificationListener(
          onNotification: (t) {
            if (t is UserScrollNotification) {
              FocusScope.of(context).requestFocus(FocusNode());
              return widget.onScroll == null ? null : widget.onScroll();
            }
            return null;
          },
          child: widget.child,
        ),
        if (showSearchScreen)
          Positioned.fill(
              child: SearchResultView(
            controller: widget.controller,
            onUsername: (val) {
              final text = widget.controller.text;

              final lastIndex = text.lastIndexOf(" ");

              widget.controller.text =
                  text.substring(0, lastIndex < 0 ? 0 : lastIndex) +
                      '${lastIndex < 0 ? '' : ' '}$val ';
              setState(() {
                showSearchScreen = false;
              });
            },
          )),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedOpacity(
            opacity: widget.showTextField ? 1 : 0,
            duration: Duration(milliseconds: 500),
            child: Visibility(
              visible: widget.showTextField,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (widget.replyingTo != null)
                    Container(
                      color: Colors.grey[200],
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Replying to ${widget.replyingTo.owner.username}',
                                style: TextStyle(color: Colors.grey),
                              )),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                widget.replyingTo = null;
                                widget.controller.clear();
                              });

                              return widget.onClear();
                            },
                            icon: Icon(
                              LineIcons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  EmojiPicker(
                    onEmoji: (e) => widget.controller.text += e,
                  ),
                  CommentTextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    onSendPressed: (val) {
                      widget.controller.clear();
                      return widget.onSend(val);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
