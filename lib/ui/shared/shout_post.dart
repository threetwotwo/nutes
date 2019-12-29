import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:vibrate/vibrate.dart';

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

class GridShoutBubble extends StatelessWidget {
  final Map data;
  final bool isChallenger;
  final double avatarSize;
  final double fontSize;

  const GridShoutBubble({
    Key key,
    this.data,
    this.isChallenger,
    this.avatarSize = 36,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = isChallenger
        ? data['challenger_text'] ?? ''
        : data['challenged_text'] ?? '';

    final user = User.fromMap(
        isChallenger ? data['challenger'] ?? {} : data['challenged'] ?? {});

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isChallenger)
          Container(
            width: avatarSize,
//            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: AvatarImage(
              url: user.urls.small,
              spacing: 0,
              padding: 0,
            ),
          ),
        Expanded(
          child: Bubble(
            alignment:
                isChallenger ? Alignment.bottomLeft : Alignment.bottomRight,
            shadowColor: Colors.black,
            color: isChallenger ? Colors.white : Colors.blueAccent[400],
//            padding: BubbleEdges.symmetric(vertical: 5, horizontal: 5),
//            margin: BubbleEdges.only(top: 5),
//            nip: isChallenger ? BubbleNip.leftBottom : BubbleNip.rightBottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isChallenger
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  user.username,
                  style: isChallenger
                      ? kPeerTextStyle.copyWith(fontSize: fontSize)
                      : kMyTextStyle.copyWith(fontSize: fontSize),
                ),
                Text(
                  content,
                  style: isChallenger
                      ? kPeerTextStyle.copyWith(fontSize: fontSize)
                      : kMyTextStyle.copyWith(fontSize: fontSize),
//                  maxLines: 4,
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),
        ),
        if (!isChallenger)
          Container(
            width: avatarSize,
//            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: AvatarImage(
              url: user.urls.small,
              spacing: 0,
              padding: 0,
            ),
          ),
      ],
    );
  }
}

class ShoutPostBubble extends StatelessWidget {
  final Post post;
  final bool isChallenger;
  final VoidCallback onHeartTapped;

  final bool didLike;
  final PostStats stats;

  final int likeCount;

  const ShoutPostBubble({
    @required this.post,
    @required this.isChallenger,
    this.onHeartTapped,
    this.didLike,
    this.stats,
    this.likeCount,

//    this.showBullhorn = true,
  });

  @override
  Widget build(BuildContext context) {
    final data = post.metadata ?? {};
    final content = isChallenger
        ? data['challenger_text'] ?? ''
        : data['challenged_text'] ?? '';

    final user = User.fromMap(
        isChallenger ? data['challenger'] ?? {} : data['challenged'] ?? {});

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (isChallenger)
              GestureDetector(
                onTap: () =>
                    Navigator.push(context, ProfileScreen.route(user.uid)),
                child: Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: AvatarImage(
                    url: user.urls.small,
                    spacing: 0,
                    padding: 0,
                  ),
                ),
              ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                    left: isChallenger ? 0 : 8, right: isChallenger ? 8 : 0),
                child: Bubble(
                  alignment: isChallenger
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  shadowColor: Colors.black,
                  color: isChallenger ? kPeerBubbleColor : kMyBubbleColor,
                  padding: BubbleEdges.symmetric(vertical: 10, horizontal: 10),
                  margin: BubbleEdges.only(top: 10),
                  nip: isChallenger
                      ? BubbleNip.leftBottom
                      : BubbleNip.rightBottom,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isChallenger
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: <Widget>[
                      Material(
                        color: isChallenger ? kPeerBubbleColor : kMyBubbleColor,
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context, ProfileScreen.route(user.uid)),
                          child: Text(
                            user.username,
                            style: isChallenger
                                ? kPeerTextStyle.copyWith(
                                    fontWeight: FontWeight.w500)
                                : kMyTextStyle.copyWith(
                                    fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        content,
                        style: isChallenger ? kPeerTextStyle : kMyTextStyle,
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (!isChallenger && likeCount > 0)
                            Material(
                              color: isChallenger
                                  ? kPeerBubbleColor
                                  : kMyBubbleColor,
                              child: InkWell(
                                onTap: () => print('tapped shout like count'),
                                child: Text(
                                  likeCount.toString() +
                                      ' ${likeCount > 1 ? 'likes' : 'like'}',
                                  style: isChallenger
                                      ? kPeerTextStyle
                                      : kMyTextStyle,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              Vibrate.feedback(FeedbackType.selection);
                              return onHeartTapped();
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 0.0,
                                bottom: 0.0,
                                right: isChallenger ? 4.0 : 0.0,
                                left: !isChallenger ? 4.0 : 0.0,
                              ),
                              child: Icon(
                                didLike == null
                                    ? Icons.ac_unit
                                    : didLike
                                        ? LineIcons.heart
                                        : LineIcons.heart_o,
                                size: 20,
                                color: didLike == null
                                    ? Colors.transparent
                                    : didLike
                                        ? isChallenger
                                            ? Colors.pink[300]
                                            : Colors.white
                                        : isChallenger
                                            ? Colors.grey
                                            : Colors.white,
                              ),
                            ),
                          ),
                          if (isChallenger && likeCount > 0)
                            Material(
                              color: isChallenger
                                  ? kPeerBubbleColor
                                  : kMyBubbleColor,
                              child: InkWell(
                                onTap: () => print('tapped shout like count'),
                                child: Text(
                                  likeCount.toString() +
                                      ' ${likeCount > 1 ? 'likes' : 'like'}',
                                  style: isChallenger
                                      ? kLabelTextStyle
                                      : kLabelTextStyle.copyWith(
                                          color: Colors.white),
                                ),
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isChallenger)
              GestureDetector(
                onTap: () =>
                    Navigator.push(context, ProfileScreen.route(user.uid)),
                child: Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: AvatarImage(
                    url: user.urls.small,
                    spacing: 0,
                    padding: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
