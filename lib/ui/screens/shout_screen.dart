import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:bubble/bubble.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:nutes/ui/widgets/chat_bubble.dart';

///Screen that allows user to respond to a shout challenge
///
class ShoutScreen extends StatefulWidget {
  final String chatId;
  final ChatItem message;
  final User challenger;
  final Function(String) onSendPressed;

  ShoutScreen(
      {Key key, this.message, this.challenger, this.onSendPressed, this.chatId})
      : super(key: key);

  static Route route() => null;

  @override
  _ShoutScreenState createState() => _ShoutScreenState();
}

class _ShoutScreenState extends State<ShoutScreen> {
  final controller = TextEditingController();

  bool finishedEditing = false;

  final auth = Auth.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: BaseAppBar(
        onTrailingPressed: () => showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: Text('Who can see this?'),
                  content: Text('\nOnce you choose to respond'
                      ', followers from both parties can view and '
                      'vote on the responses. \n\n'
                      'Unanswered shouts will be removed from your inbox '
                      'within 24 hours.'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                    )
                  ],
                )),
        title: Text(
          'Shout with ${widget.challenger.username}',
          overflow: TextOverflow.fade,
          style: TextStyles.w600Text,
        ),
        trailing: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            LineIcons.info_circle,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: size.width,
          color: Colors.grey[100],
          child: ListView(
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: SizedBox(
                          width: 50,
                          child: AvatarImage(
                              spacing: 0,
                              url: this.widget.challenger.urls.small)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Bubble(
                        alignment: Alignment.centerLeft,
                        shadowColor: Colors.black,
                        color: Colors.white,
                        nip: BubbleNip.leftBottom,
                        padding:
                            BubbleEdges.symmetric(vertical: 10, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.challenger.username,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: kPeerTextColor,
                                  fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              widget.message.content,
                              style: TextStyle(
                                  color: kPeerTextColor, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: size.width * 0.7),
                      child: Bubble(
                        color: Colors.blueAccent[400],
                        nip: BubbleNip.rightBottom,
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                auth.profile.user.username,
                                style: TextStyles.w600Text
                                    .copyWith(color: Colors.white),
                                maxLines: 1,
                              ),
                              SizedBox(height: 10),
                              finishedEditing
                                  ? Text(
                                      controller.text,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Expanded(
                                            child: TextField(
                                              style: TextStyle(
                                                  color: Colors.white),
                                              controller: this.controller,
                                              minLines: 1,
                                              maxLines: 15,
                                              maxLength: 800,
                                              cursorColor: Colors.white,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  counterText: '',
                                                  hintStyle: TextStyle(
                                                      color: Colors.white),
                                                  hintText:
                                                      'What is your reply?'),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(200),
                                                splashColor: Colors.white,
                                                onTap: () {
                                                  if (this
                                                          .controller
                                                          .text
                                                          .isEmpty ||
                                                      this.controller.text ==
                                                          null) return;
                                                  print('send tapped');
                                                  _showConfirmSendDialog(
                                                      context);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Send',
                                                    style: TextStyles.w600Text
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(
                                            color: Colors.grey[300],
                                            width: 1.4),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: SizedBox(
                          width: 50,
                          child: AvatarImage(
                              spacing: 0, url: auth.profile.user.urls.small)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmSendDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text('Start a shout?'),
              content: Text('\nOnce the other person '
                  'responds, shouts become public and anyone can '
                  'vote on the responses.\n'
                  '\nUnanswered shouts will be removed '
                  'from '
                  'your '
                  'inbox within 24 hours.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Cancel'),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
                CupertinoDialogAction(
                  child: Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    setState(() {
                      finishedEditing = true;
                    });

                    Navigator.of(context, rootNavigator: true).pop();
                    return _completeShoutChallenge();
                  },
                ),
              ],
            ));
  }

  Future _completeShoutChallenge() async {
    final metadata = {
      'challenger': widget.challenger.toMap(),
      'challenged': auth.profile.toMap(),
      'challenger_text': widget.message.content,
      'challenged_text': controller.text,
    };

    Repo.completeShoutChallenge(
        chatId: widget.chatId,
        messageId: widget.message.id,
        content: widget.message.content,
        response: controller.text,
        peer: widget.challenger);

//    await Repo.uploadPublicShout(peer: widget.challenger, data: metadata);

    await Repo.uploadShoutPost(peer: widget.challenger, data: metadata);
    return Navigator.pop(context);
  }
}
