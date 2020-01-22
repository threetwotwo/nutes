import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/events/events.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/events.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:bubble/bubble.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:nutes/ui/widgets/chat_bubble.dart';

///Screen that allows user to respond to a shout challenge
///
class ShoutScreen extends StatefulWidget {
  final String chatId;
  final String messageId;
  final String content;
  final String topic;
  final User peer;

  ShoutScreen({
    Key key,
    this.messageId,
    this.content,
    this.peer,
    this.chatId,
    this.topic,
  }) : super(key: key);

  static Route route({
    @required String chatId,
    @required User peer,
    @required String messageId,
    @required String content,
    @required String topic,
  }) =>
      MaterialPageRoute(builder: (context) {
        return ShoutScreen(
          chatId: chatId,
          peer: peer,
          messageId: messageId,
          content: content,
          topic: topic,
        );
      });

  @override
  _ShoutScreenState createState() => _ShoutScreenState();
}

class _ShoutScreenState extends State<ShoutScreen> {
  final controller = TextEditingController();

  bool finishedEditing = false;

  final auth = Repo.auth;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: BaseAppBar(
        onTrailingPressed: () => showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: Text('Who can see this?'),
                  content: Text(
                      '\nOnce you choose to respond, followers of both parties can view the shout on their feeds.'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                    )
                  ],
                )),
        title: Text(
          'Shout with ${widget.peer.username}',
          overflow: TextOverflow.fade,
          style: TextStyles.header,
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
          color: Colors.grey[50],
          child: ListView(
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.topic?.isNotEmpty ?? false)
                EmptyIndicator('Topic: ${widget.topic}'),

              ///Peer bubble
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.all(4.0),
                        width: 48,
                        child: AvatarImage(
                          url: this.widget.peer.urls.small,
                          spacing: 0,
                          padding: 0,
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65),
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
                              widget.peer.username,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: kPeerTextColor,
                                  fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              widget.content,
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

              ///Your response bubble
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: size.width * 0.65),
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
                                auth.user.username,
                                style: TextStyles.w600Text
                                    .copyWith(color: Colors.white),
                                maxLines: 1,
                              ),
                              SizedBox(height: 8),
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
                                                      'What is your response?'),
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
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 48,
                        child: AvatarImage(
                          url: auth.user.urls.small,
                          spacing: 0,
                          padding: 0,
                        )),
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
              content: Text(
                  '\nOnce you choose to respond, followers of both parties can view the shout on their feeds.'),
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
      'challenger': widget.peer.toMap(),
      'challenged': auth.user.toMap(),
      'challenger_text': widget.content,
      'challenged_text': controller.text.trim(),
      if (widget.topic != null) 'topic': widget.topic,
    };

    final post = await Repo.uploadShoutPost(peer: widget.peer, data: metadata);

    eventBus.fire(PostUploadEvent(post));

    Repo.completeShoutChallenge(
      postId: post.id,
      chatId: widget.chatId,
      messageId: widget.messageId,
      content: widget.content,
      response: controller.text,
      peer: widget.peer,
    );

    return Navigator.pop(context);
  }
}
