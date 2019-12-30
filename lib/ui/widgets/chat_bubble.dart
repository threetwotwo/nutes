import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/screens/post_detail_page.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:intl/intl.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/chat_post_content.dart';
import 'package:nutes/utils/timeAgo.dart';

final kPeerBubbleColor = Colors.white;
const kPeerTextColor = Colors.black;
final kMyBubbleColor = Colors.blueAccent[700];
const kMyTextColor = Colors.white;

final kPeerTextStyle =
    TextStyles.defaultText.copyWith(color: kPeerTextColor, fontSize: 16);
final kMyTextStyle =
    TextStyles.defaultText.copyWith(color: kMyTextColor, fontSize: 16);

final kLabelTextStyle =
    TextStyles.w600Text.copyWith(color: Colors.grey, fontSize: 12);

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
        width: 32,
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

  final bool isSeen;

  const ChatTextBubble({
    @required this.isPeer,
    @required this.message,
    @required this.isLast,
    @required this.peer,
    this.showDate = false,
    this.isSeen = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.75;
    final isAWeekOld = message.timestamp.toDate().millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch - 604800000;
    final isToday = message.timestamp.toDate().day < DateTime.now().day;

    final date = message.timestamp.toDate();

    return Column(
//      crossAxisAlignment:
//          isPeer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: <Widget>[
        if (showDate)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text:
                          '${isAWeekOld ? DateFormat.d().format(date) + ' ' + DateFormat.MMM().format(date) : !isToday ? 'Today' : DateFormat.EEEE().format(date)} ',
                      style: kLabelTextStyle),
                  TextSpan(
                      text: '${DateFormat.jm().format(date)}',
                      style: kLabelTextStyle.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
            ),
//            Text(
//              '${isAWeekOld ? (DateFormat.d().format(message.timestamp.toDate()) + ' ' + DateFormat.MMM().format(message.timestamp.toDate())) : !isToday ? '' : DateFormat.EEEE().format(message.timestamp.toDate())} '
//              '${DateFormat.jm().format(message.timestamp.toDate())}',
//              maxLines: 1,
//              overflow: TextOverflow.ellipsis,
//              style: kLabelTextStyle,
//            ),
          ),
        Column(
          crossAxisAlignment:
              isPeer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment:
                  isPeer ? MainAxisAlignment.start : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                ///Peer avatar
                if (isPeer)
                  ChatPeerAvatar(peer: peer, isVisible: isLast),

                ///Bubble
                Container(
//          color: Colors.green,
                  padding: kBubbleVerticalPadding,
                  constraints: BoxConstraints(maxWidth: width),
                  child: Bubble(
                    alignment:
                        isPeer ? Alignment.centerLeft : Alignment.centerRight,
                    shadowColor: isPeer ? Colors.black : Colors.black,
                    color: isPeer ? kPeerBubbleColor : kMyBubbleColor,
                    padding:
                        BubbleEdges.symmetric(vertical: 10, horizontal: 10),
                    child: Text(
                      message.content,
                      style: isPeer ? kPeerTextStyle : kMyTextStyle,
                    ),
                  ),
                ),
              ],
            ),
//            if (showDate)
//              Padding(
//                padding: isPeer
//                    ? const EdgeInsets.only(left: 44.0)
//                    : const EdgeInsets.only(right: 8.0),
//                child: Text(
//                  DateFormat.jm().format(date),
//                  style: kLabelTextStyle,
//                ),
//              ),
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

class ChatPostBubble extends StatelessWidget {
  final bool isPeer;
  final ChatItem message;

  ///Show peer avatar if true
  final bool isLast;

  final User peer;

  final bool showDate;

  final bool isSeen;

  const ChatPostBubble(
      {Key key,
      this.isPeer,
      this.message,
      this.isLast,
      this.peer,
      this.showDate,
      this.isSeen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = message.metadata;

    if (data == null || data.isEmpty) return SizedBox();

    final owner = User.fromMap(data['owner']);

//    final urls = data['urls'];

    final hasCaption = data['caption'].toString().isNotEmpty;

    return Padding(
      padding: kBubbleVerticalPadding,
      child: Column(
        crossAxisAlignment:
            isPeer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment:
                isPeer ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (isPeer)
                ChatPeerAvatar(
                  isVisible: hasCaption ? false : isLast,
                  peer: peer,
                ),

              ///Post Bubble
              GestureDetector(
                onTap: () => Navigator.of(context).push(PostDetailScreen.route(
                    null,
                    postId: data['post_id'],
                    ownerId: owner.uid)),
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[400]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ///Post header

                          Container(
                            margin: const EdgeInsets.all(4),
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    AvatarImage(
                                      url: owner.urls.small,
                                      spacing: 0,
                                      padding: 4,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      owner.username,
                                      style: TextStyles.w600Display,
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),

                          ///Divider
                          Container(
                            height: 1,
                            color: Colors.grey[300],
                          ),

                          ///Post Image
                          ChatPostContent(
                            data: data,
                          ),

                          ///Post caption
                          if (hasCaption)
                            Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: owner.username + ' ',
                                      style: TextStyles.w600Display,
                                    ),
                                    TextSpan(
                                      text: data['caption'],
                                      style: TextStyles.defaultText,
                                    )
                                  ]),
                                )),
                        ],
                      ),
                    )),
              ),
            ],
          ),

          ///Optional message
          if (message.content.isNotEmpty)
            ChatTextBubble(
              isPeer: isPeer,
              isLast: isLast,
              isSeen: isSeen,
              peer: peer,
              showDate: false,
              message: message,
            ),
        ],
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
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(children: [
                TextSpan(
                  text:
                      '${isPeer ? '${peer.username} responded to your shout' : 'You responded to a shout'}',
                  style: kLabelTextStyle,
                ),
                TextSpan(
                  text:
                      ' · ${TimeAgo.formatShort(response.timestamp.toDate())}',
                  style: kLabelTextStyle.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ]),
            ),
//            Text(
//              '${isPeer ? '${peer.username} responded to your shout' : 'You '
//                  'responded to a shout'} · ${TimeAgo.formatShort(response.timestamp.toDate())}',
//              maxLines: 1,
//              overflow: TextOverflow.ellipsis,
//              style: kLabelTextStyle,
//            ),
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
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(children: [
                  TextSpan(
                    text:
                        '${isPeer ? '${peer.username} started a shout' : 'You started a shout'}',
                    style: kLabelTextStyle,
                  ),
                  TextSpan(
                    text:
                        ' · ${TimeAgo.formatShort(message.timestamp.toDate())}',
                    style: kLabelTextStyle.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ]),
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
                                  LineIcons.volume_up,
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
