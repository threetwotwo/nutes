import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:intl/intl.dart';

const kPeerBubbleColor = Colors.white;
const kPeerTextColor = Colors.black;
final kMyBubbleColor = Colors.blueAccent[400];
const kMyTextColor = Colors.white;

const kBubbleVerticalPadding = const EdgeInsets.symmetric(vertical: 4);

class ChatPeerAvatar extends StatelessWidget {
  final bool isVisible;
  final User peer;

  const ChatPeerAvatar({Key key, @required this.isVisible, @required this.peer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileScreen(
                uid: peer.uid,
              ))),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: SizedBox(
          width: 36,
          child: Visibility(
            visible: isVisible,
            child: AvatarImage(
              url: peer.photoUrl,
              spacing: 0,
              padding: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatPlaceholderBubble extends StatelessWidget {
  final ChatItem message;

  const ChatPlaceholderBubble(this.message);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.75;

    return Container(
//          color: Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints(maxWidth: width),
      child: Bubble(
        alignment: Alignment.centerRight,
        shadowColor: Colors.transparent,
        color: Colors.grey,
        padding: BubbleEdges.symmetric(vertical: 10, horizontal: 10),
//            margin: BubbleEdges.only(top: 10),
        child: Text(
          message.content,
          style: TextStyle(color: kMyTextColor, fontSize: 16),
        ),
      ),
    );
  }
}

///A text widget that uses the [Bubble] package
///
/// For use in chat screen
class ChatTextBubble extends StatelessWidget {
  final ChatItem message;

  ///to determine if the bubble should be placed on the left or right of screen
  final bool isPeer;

  ///Show peer avatar if true
  final bool isLast;

  final User peer;

  final bool showDate;

  const ChatTextBubble({
    @required this.isPeer,
    @required this.message,
    @required this.isLast,
    @required this.peer,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.75;
    final isAWeekOld = message.timestamp.toDate().millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch - 604800000;
//    print(message.timestamp.toDate().second);
//    print(DateTime.now().second);
    return Column(
      children: <Widget>[
        if (showDate)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${isAWeekOld ? (DateFormat.d().format(message.timestamp.toDate()) + ' ' + DateFormat.MMM().format(message.timestamp.toDate())) : DateFormat.EEEE().format(message.timestamp.toDate())} '
              '${DateFormat.jm().format(message.timestamp.toDate())}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        Row(
          mainAxisAlignment:
              isPeer ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (isPeer) ChatPeerAvatar(peer: peer, isVisible: isLast),
            Container(
//          color: Colors.green,
              padding: kBubbleVerticalPadding,
              constraints: BoxConstraints(maxWidth: width),
              child: Bubble(
                alignment:
                    isPeer ? Alignment.centerLeft : Alignment.centerRight,
                shadowColor: isPeer ? Colors.transparent : Colors.transparent,
                color: isPeer ? Colors.grey[100] : Colors.blueAccent[400],
                padding: BubbleEdges.symmetric(vertical: 10, horizontal: 10),
//            margin: BubbleEdges.only(top: 10),
                child: Text(
                  message.content,
                  style: TextStyle(
                      color: isPeer ? Colors.black : Colors.white,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TypingIndicator extends StatelessWidget {
  final User user;

  const TypingIndicator({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: () {},
        child: Text('${user.username} is '
            'typing...'));
  }
}

class ChatShoutResponseBubble extends StatelessWidget {
  final bool isPeer;
  final String content;
  final String response;
  final User peer;
  final VoidCallback onTapped;
  final bool isLast;

  const ChatShoutResponseBubble(
      {Key key,
      @required this.isPeer,
      @required this.content,
      @required this.response,
      @required this.peer,
      @required this.onTapped,
      @required this.isLast})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              isPeer
                  ? '${peer.username} responded to your shout'
                  : 'You responded to a shout',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        Row(
          mainAxisAlignment:
              isPeer ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (isPeer) ChatPeerAvatar(peer: peer, isVisible: isLast),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: GestureDetector(
                onTap: onTapped,
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: isPeer
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: <Widget>[
                      Bubble(
//                alignment: Alignment.centerLeft,
                        shadowColor: Colors.black,
                        color: isPeer ? kMyBubbleColor : kPeerBubbleColor,
                        nip: isPeer
                            ? BubbleNip.rightBottom
                            : BubbleNip.leftBottom,
                        child: Column(
                          crossAxisAlignment: isPeer
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              isPeer
                                  ? Repo.currentProfile.user.username
                                  : peer.username,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: isPeer ? kMyTextColor : kPeerTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              response,
                              maxLines: 4,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                color: isPeer ? kMyTextColor : kPeerTextColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        child: Bubble(
                          alignment: isPeer
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          shadowColor: Colors.black,
                          color: isPeer ? kPeerBubbleColor : kMyBubbleColor,
                          nip: isPeer
                              ? BubbleNip.leftBottom
                              : BubbleNip.rightBottom,
                          child: Column(
                            crossAxisAlignment: isPeer
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                isPeer
                                    ? peer.username
                                    : Repo.currentProfile.user.username,
                                style: TextStyle(
                                    color:
                                        !isPeer ? kMyTextColor : kPeerTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 8),
                              Text(
                                content,
                                style: TextStyle(
                                  color:
                                      !isPeer ? kMyTextColor : kPeerTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ChatShoutBubble extends StatelessWidget {
  final bool isPeer;
  final String content;
  final VoidCallback onTapped;
  final User peer;
  final bool isLast;

  const ChatShoutBubble({
    @required this.isPeer,
    @required this.content,
    @required this.onTapped,
    @required this.peer,
    @required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPeer ? onTapped : null,
      child: Column(
        crossAxisAlignment:
            isPeer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                isPeer
                    ? '${peer.username} started a shout'
                    : 'You started a '
                        'shout',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(
//            color: Colors.yellow,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Row(
              mainAxisAlignment:
                  isPeer ? MainAxisAlignment.start : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (isPeer) ChatPeerAvatar(peer: peer, isVisible: isLast),
                Expanded(
                  child: Bubble(
                    alignment:
                        isPeer ? Alignment.centerLeft : Alignment.centerRight,
//                    color: Color(0xFFDCF8C8),
                    shadowColor: Colors.black,

                    color: isPeer ? kPeerBubbleColor : kMyBubbleColor,
//                    nip: isPeer ? BubbleNip.leftBottom : BubbleNip.rightBottom,
                    child: Stack(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: isPeer
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  isPeer
                                      ? peer.username
                                      : Repo.currentProfile.user.username,
                                  style: TextStyle(
                                      color: isPeer
                                          ? kPeerTextColor
                                          : kMyTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              content,
                              style: TextStyle(
                                color: isPeer ? kPeerTextColor : kMyTextColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (isPeer)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.black.withOpacity(0.35),
                                child: Icon(
                                  LineIcons.bullhorn,
                                  color: Colors.white.withOpacity(0.95),
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
