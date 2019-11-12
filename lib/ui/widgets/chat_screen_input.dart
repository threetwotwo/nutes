import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/ui/widgets/shout_text_field.dart';

class ChatScreenInput extends StatefulWidget {
  final VoidCallback onImagePressed;
  final VoidCallback showModalBottomSheet;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onSendPressed;

  const ChatScreenInput(
      {Key key,
      this.onImagePressed,
      this.showModalBottomSheet,
      this.controller,
      this.focusNode,
      this.onSendPressed})
      : super(key: key);

  @override
  _ChatScreenInputState createState() => _ChatScreenInputState();
}

class _ChatScreenInputState extends State<ChatScreenInput> {
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
    final primaryColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(32),
          color: primaryColor,
        ),
        child: Row(
          crossAxisAlignment: _alignment,
          children: <Widget>[
            // Button send image
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                type: MaterialType.button,
                borderRadius: BorderRadius.circular(80),
                color: Colors.blueAccent,
                child: IconButton(
                  icon: Icon(
                    LineIcons.image,
                    color: Colors.white,
                  ),
                  onPressed: widget.onImagePressed,
                  color: Colors.black,
                ),
              ),
            ),

            // Edit text
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  minLines: 1,
                  maxLines: 6,
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                  controller: widget.controller,
                  decoration: InputDecoration(
//                  filled: true,
//                  fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.all(8),
                    border: InputBorder.none,
//                  border: OutlineInputBorder(
//                      borderRadius: BorderRadius.circular(16),
//                      borderSide: BorderSide(color: Colors.grey, width: 0.5)),
//                  focusedBorder: OutlineInputBorder(
//                      borderRadius: BorderRadius.circular(16),
//                      borderSide: BorderSide(color: Colors.grey, width: 0.5)),
                    hintText: 'Message',
                    hintStyle: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w300),
                  ),
                  focusNode: widget.focusNode,
                ),
              ),
            ),

            // Button send message
            AnimatedOpacity(
              opacity: isTyping ? 1 : 0,
              duration: Duration(milliseconds: 400),
              child: Visibility(
                visible: isTyping,
                child: FlatButton(
                    onPressed: widget.onSendPressed,
                    child: Text(
                      'Send',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 17),
                    )),
//              child: Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: CircleAvatar(
//                  backgroundColor: Colors.blueAccent[400],
//                  child: IconButton(
//                    icon: Icon(
//                      Icons.send,
//                      color: Colors.white,
//                      size: 22,
//                    ),
//                    onPressed: widget.onSendPressed,
//                  ),
////            color: primaryColor,
//                ),
//              ),
              ),
            ),
            if (!isTyping)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedOpacity(
                  opacity: !isTyping ? 1 : 0,
                  duration: Duration(milliseconds: 400),
                  child: Visibility(
                    visible: !isTyping,
                    child: Material(
                      borderRadius: BorderRadius.circular(32),
                      child: IconButton(
                        icon: Icon(
                          LineIcons.bullhorn,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title: Text('Start a shout?'),
                                    content: Text('\nOnce the other person '
                                        'responds, the shout become public and '
                                        'followers of both parties can view it.\n'
                                        '\nShouts expire within 24 hours.'),
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
                                          return widget.showModalBottomSheet();
                                        },
                                      ),
                                    ],
                                  ));
                        },
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
