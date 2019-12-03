import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/shared/avatar_image.dart';

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
  CrossAxisAlignment _alignment = CrossAxisAlignment.center;
  final tf = TextField();

  @override
  void initState() {
    widget.controller.addListener(() {
      if (widget.controller.text.isNotEmpty)
        setState(() {
          isTyping = true;

          _alignment = CrossAxisAlignment.end;
        });
      else
        setState(() {
          isTyping = false;
          _alignment = CrossAxisAlignment.center;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300])),
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 36,
//                  child: AvatarImage(
//                    url: Auth.instance.profile.user.photoUrl,
//                    padding: 2,
//                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 800,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
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
                        color: Colors.white,
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
                            LineIcons.camera,
                            color: Colors.blueAccent,
                          ),
                          onTap: widget.onImagePressed,
                        ),
                      ),
                    ),
                  ),
                ),

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
                            LineIcons.bullhorn,
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
      ],
    );
//    return Padding(
//      padding: const EdgeInsets.all(8.0),
//      child: Container(
//        width: MediaQuery.of(context).size.width * 0.8,
//        decoration: BoxDecoration(
//          border: Border.all(color: Colors.grey, width: 0.5),
//          borderRadius: BorderRadius.circular(32),
//          color: primaryColor,
//        ),
//        child: Row(
//          crossAxisAlignment: _alignment,
//          children: <Widget>[
//            // Button send image
//            Container(
//              padding: const EdgeInsets.all(8.0),
//              child: Material(
//                type: MaterialType.button,
//                borderRadius: BorderRadius.circular(80),
//                color: Colors.blueAccent,
//                child: IconButton(
//                  icon: Icon(
//                    LineIcons.image,
//                    color: Colors.white,
//                  ),
//                  onPressed: widget.onImagePressed,
//                  color: Colors.black,
//                ),
//              ),
//            ),
//
//            // Edit text
//            Flexible(
//              child: Container(
//                padding: const EdgeInsets.all(8),
//                child: TextField(
//                  minLines: 1,
//                  maxLines: 6,
//                  style: TextStyle(color: Colors.black, fontSize: 16.0),
//                  controller: widget.controller,
//                  decoration: InputDecoration(
////                  filled: true,
////                  fillColor: Colors.grey[100],
//                    contentPadding: EdgeInsets.all(8),
//                    border: InputBorder.none,
////                  border: OutlineInputBorder(
////                      borderRadius: BorderRadius.circular(16),
////                      borderSide: BorderSide(color: Colors.grey, width: 0.5)),
////                  focusedBorder: OutlineInputBorder(
////                      borderRadius: BorderRadius.circular(16),
////                      borderSide: BorderSide(color: Colors.grey, width: 0.5)),
//                    hintText: 'Message',
//                    hintStyle: TextStyle(
//                        color: Colors.grey, fontWeight: FontWeight.w300),
//                  ),
//                  focusNode: widget.focusNode,
//                ),
//              ),
//            ),
//
//            // Button send message
//            AnimatedOpacity(
//              opacity: isTyping ? 1 : 0,
//              duration: Duration(milliseconds: 400),
//              child: Visibility(
//                visible: isTyping,
//                child: FlatButton(
//                    onPressed: widget.onSendPressed,
//                    child: Text(
//                      'Send',
//                      style: TextStyle(color: Colors.blueAccent, fontSize: 17),
//                    )),
////              child: Padding(
////                padding: const EdgeInsets.all(8.0),
////                child: CircleAvatar(
////                  backgroundColor: Colors.blueAccent[400],
////                  child: IconButton(
////                    icon: Icon(
////                      Icons.send,
////                      color: Colors.white,
////                      size: 22,
////                    ),
////                    onPressed: widget.onSendPressed,
////                  ),
//////            color: primaryColor,
////                ),
////              ),
//              ),
//            ),
//            if (!isTyping)
//              Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: AnimatedOpacity(
//                  opacity: !isTyping ? 1 : 0,
//                  duration: Duration(milliseconds: 400),
//                  child: Visibility(
//                    visible: !isTyping,
//                    child: Material(
//                      borderRadius: BorderRadius.circular(32),
//                      child: IconButton(
//                        icon: Icon(
//                          LineIcons.bullhorn,
//                          color: Colors.blueAccent,
//                        ),
//                        onPressed: () {
//                          showDialog(
//                              context: context,
//                              builder: (context) => CupertinoAlertDialog(
//                                    title: Text('Start a shout?'),
//                                    content: Text('\nOnce the other person '
//                                        'responds, the shout becomes public '
//                                        'and can be viewed by '
//                                        'followers of both parties.'),
//                                    actions: <Widget>[
//                                      CupertinoDialogAction(
//                                          child: Text('Cancel'),
//                                          onPressed: () => _pop(context)),
//                                      CupertinoDialogAction(
//                                        child: Text(
//                                          'OK',
//                                          style: TextStyle(
//                                              fontWeight: FontWeight.w600),
//                                        ),
//                                        onPressed: () {
//                                          print('shout ok pressed');
//
//                                          _pop(context);
//                                          return widget.showModalBottomSheet();
//                                        },
//                                      ),
//                                    ],
//                                  ));
//                        },
//                        color: primaryColor,
//                      ),
//                    ),
//                  ),
//                ),
//              ),
//          ],
//        ),
//      ),
//    );
  }
}
