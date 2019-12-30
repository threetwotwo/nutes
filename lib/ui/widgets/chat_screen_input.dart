import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/ui/shared/styles.dart';

class ChatTextField extends StatefulWidget {
  final VoidCallback onImagePressed;
  final VoidCallback showModalBottomSheet;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onSendPressed;

  const ChatTextField(
      {Key key,
      this.onImagePressed,
      this.showModalBottomSheet,
      this.controller,
      this.focusNode,
      this.onSendPressed})
      : super(key: key);

  @override
  _ChatTextFieldState createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  _pop(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  bool isTyping = false;
  CrossAxisAlignment alignment = CrossAxisAlignment.center;

  @override
  void initState() {
    widget.controller.addListener(() {
      if (widget.controller.text.isNotEmpty)
        setState(() {
          isTyping = true;

          alignment = CrossAxisAlignment.end;
        });
      else
        setState(() {
          isTyping = false;
          alignment = CrossAxisAlignment.center;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(top: BorderSide(color: Colors.grey[300])),
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8,
//                  child: AvatarImage(
//                    url: Auth.instance.profile.user.photoUrl,
//                    padding: 2,
//                  ),
                ),
                Expanded(
                  child: TextField(
                    style: TextStyles.defaultText,
                    controller: widget.controller,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 800,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        counterText: '',
                        hintText: 'Message'),
                  ),
                ),

                ///Send Button
                AnimatedOpacity(
                  opacity: isTyping ? 1 : 0,
                  duration: Duration(milliseconds: 400),
                  child: Visibility(
                    visible: isTyping,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          child: Icon(
                            Icons.send,
                            color: Colors.blueAccent,
                          ),
                          onTap: widget.onSendPressed,
                        ),
                      ),
                    ),
                  ),
                ),

                ///Image Button
//                AnimatedOpacity(
//                  opacity: !isTyping ? 1 : 0,
//                  duration: Duration(milliseconds: 400),
//                  child: Visibility(
//                    visible: !isTyping,
//                    child: Padding(
//                      padding: const EdgeInsets.symmetric(
//                          vertical: 4.0, horizontal: 8),
//                      child: Material(
//                        color: Colors.white,
//                        child: InkWell(
//                          child: Icon(
//                            LineIcons.camera,
//                            color: Colors.blueAccent,
//                          ),
//                          onTap: widget.onImagePressed,
//                        ),
//                      ),
//                    ),
//                  ),
//                ),

                ///Shout Button
                AnimatedOpacity(
                  opacity: !isTyping ? 1 : 0,
                  duration: Duration(milliseconds: 400),
                  child: Visibility(
                    visible: !isTyping,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8),
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          child: Icon(
                            LineIcons.volume_up,
                            color: Colors.blueAccent,
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                      title: Text('Start a shout?'),
                                      content: Text('\nOnce the other person '
                                          'responds, the shout becomes public '
                                          'and can be viewed by '
                                          'followers of both parties.'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                            child: Text('Cancel'),
                                            onPressed: () => _pop(context)),
                                        CupertinoDialogAction(
                                          child: Text(
                                            'OK',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          onPressed: () {
                                            print('shout ok pressed');

                                            _pop(context);
                                            return widget
                                                .showModalBottomSheet();
                                          },
                                        ),
                                      ],
                                    ));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
