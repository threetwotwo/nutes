import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShoutPost extends StatelessWidget {
  const ShoutPost({
    Key key,
    @required this.post,
    this.isGrid = false,
  }) : super(key: key);

  final Post post;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    return isGrid
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GridShoutBubble(
                post: post,
                isChallenger: true,
              ),
              Expanded(
                child: ClipRect(
                  child: GridShoutBubble(
                    post: post,
                    isChallenger: false,
                  ),
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ShoutPostBubble(
                  isChallenger: true,
                  post: post,
                ),
              ),
              Expanded(
                child: ShoutPostBubble(
                  isChallenger: false,
                  post: post,
                ),
              ),
            ],
          );
  }
}

class GridShoutBubble extends StatelessWidget {
  final Post post;
  final bool isChallenger;

  const GridShoutBubble({Key key, this.post, this.isChallenger})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = post.metadata ?? {};
    final content = isChallenger
        ? data['challenger_text'] ?? ''
        : data['challenged_text'] ?? '';

    final user = User.fromMap(
        isChallenger ? data['challenger'] ?? {} : data['challenged'] ?? {});

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (isChallenger)
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[100], width: 0.6)),
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CircleAvatar(
                foregroundColor: Colors.grey[100],
                radius: 14,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl)),
          ),
        Expanded(
          child: Bubble(
            alignment:
                isChallenger ? Alignment.bottomLeft : Alignment.bottomRight,
            shadowColor: Colors.black,
            color: isChallenger ? Colors.white : Colors.blueAccent[400],
            padding: BubbleEdges.symmetric(vertical: 5, horizontal: 5),
            margin: BubbleEdges.only(top: 5),
            nip: isChallenger ? BubbleNip.leftBottom : BubbleNip.rightBottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isChallenger
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  user.username,
                  style: TextStyle(
                      color: isChallenger ? Colors.black : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
//          SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyles.defaultText.copyWith(
                    color: isChallenger ? Colors.black : Colors.white,
                  ),
//                  maxLines: 4,
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),
        ),
        if (!isChallenger)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[100], width: 0.6)),
            child: CircleAvatar(
                foregroundColor: Colors.grey[100],
                radius: 14,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl)),
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

  const ShoutPostBubble({
    this.post,
    this.isChallenger,
    this.onHeartTapped,
    this.didLike,
    this.stats,

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
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl)),
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
                  color: isChallenger ? Colors.grey[100] : Colors.blueAccent,
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
                        color:
                            isChallenger ? Colors.grey[100] : Colors.blueAccent,
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context, ProfileScreen.route(user.uid)),
                          child: Text(
                            user.username,
                            style: TextStyle(
                                color:
                                    isChallenger ? Colors.black : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        content,
                        style: TextStyles.defaultText.copyWith(
                            color: isChallenger ? Colors.black : Colors.white),
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                            onTap: onHeartTapped,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Icon(
                                  didLike ? LineIcons.heart : LineIcons.heart_o,
                                  size: 20,
                                  color: didLike
                                      ? isChallenger
                                          ? Colors.pink[300]
                                          : Colors.white
                                      : isChallenger
                                          ? Colors.grey
                                          : Colors.white),
                            ),
                          ),
                          Text(
                            isChallenger
                                ? stats.challengerCount.toString() + ' likes'
                                : stats.challengedCount.toString() + ' likes',
                            style: TextStyle(
                                color:
                                    isChallenger ? Colors.grey : Colors.white),
                          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: CircleAvatar(
                      backgroundColor: Colors.grey[100],
//                    radius: 14,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
