import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/shout_post.dart';

class ShoutGridItem extends StatelessWidget {
  final double avatarSize;
  final double fontSize;

  const ShoutGridItem({
    Key key,
    @required this.metadata,
    this.avatarSize = 36,
    this.fontSize = 14,
  }) : super(key: key);

  final Map metadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: GridShoutBubble(
              isChallenger: true,
              data: metadata,
              avatarSize: avatarSize,
              fontSize: fontSize,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: GridShoutBubble(
              isChallenger: false,
              data: metadata,
              avatarSize: avatarSize,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
