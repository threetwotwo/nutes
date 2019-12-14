import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:intl/intl.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/timeAgo.dart';

final kPeerBubbleColor = Colors.white;
const kPeerTextColor = Colors.black;
final kMyBubbleColor = Colors.blueAccent[400];
const kMyTextColor = Colors.white;

final kPeerTextStyle =
    TextStyles.defaultText.copyWith(color: kPeerTextColor, fontSize: 16);
final kMyTextStyle =
    TextStyles.defaultText.copyWith(color: kMyTextColor, fontSize: 16);

final kLabelTextStyle =
    TextStyles.defaultText.copyWith(color: Colors.grey, fontSize: 14);

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
      child: SizedBox(
        width: 36,
        child: Visibility(
          visible: isVisible,
          child: AvatarImage(
            url: peer.urls.small,
            spacing: 0,
            padding: 0,
          ),
        ),
      ),
    );
  }
}

class ChatPlaceholderBubble extends StatelessWidget {
  final ChatItem message;
  final auth = Auth.instance;

  ChatPlaceholderBubble(this.message);

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
          style: kMyTextStyle,
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
              style: kLabelTextStyle,
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
                shadowColor: isPeer ? Colors.black : Colors.black,
                color: isPeer ? kPeerBubbleColor : kMyBubbleColor,
                padding: BubbleEdges.symmetric(vertical: 10, horizontal: 10),
                child: Text(
                  message.content,
                  style: isPeer ? kPeerTextStyle : kMyTextStyle,
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
      child: Text(
        '${user.username} is '
        'typing...',
        style: kLabelTextStyle,
      ),
    );
  }
}

class ChatShoutResponseBubble extends StatelessWidget {
  final bool isPeer;
  final ChatItem response;
  final String message;
  final User peer;
  final VoidCallback onTapped;
  final bool isLast;

  final auth = Auth.instance;

  ChatShoutResponseBubble(
      {Key key,
      @required this.isPeer,
      @required this.response,
      @required this.message,
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
              '${isPeer ? '${peer.username} responded to your shout' : 'You '
                  'responded to a shout'} · ${TimeAgo.formatShort(response.timestamp.toDate())}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: kLabelTextStyle,
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
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: GestureDetector(
                onTap: onTapped,
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                                  ? auth.profile.user.username
                                  : peer.username,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: isPeer ? kMyTextStyle : kPeerTextStyle,
                            ),
                            SizedBox(height: 8),
                            Text(
                              message,
                              maxLines: 4,
                              overflow: TextOverflow.fade,
                              style: isPeer ? kMyTextStyle : kPeerTextStyle,
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
                                    : auth.profile.user.username,
                                style: !isPeer ? kMyTextStyle : kPeerTextStyle,
                              ),
                              SizedBox(height: 8),
                              Text(
                                response.content,
                                style: !isPeer ? kMyTextStyle : kPeerTextStyle,
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
  final ChatItem message;
  final VoidCallback onTapped;
  final User peer;
  final bool isLast;

  const ChatShoutBubble({
    @required this.isPeer,
    @required this.message,
    @required this.onTapped,
    @required this.peer,
    @required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Auth.instance;

    return GestureDetector(
      onTap: isPeer ? onTapped : null,
      child: Column(
        crossAxisAlignment:
            isPeer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${isPeer ? '${peer.username} started a shout' : 'You started'
                        ' a shout'}' +
                    ' · ${TimeAgo.formatShort(message.timestamp.toDate())}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kLabelTextStyle,
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
                                      : auth.profile.user.username,
                                  style:
                                      !isPeer ? kMyTextStyle : kPeerTextStyle,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              message.content,
                              style: !isPeer ? kMyTextStyle : kPeerTextStyle,
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
