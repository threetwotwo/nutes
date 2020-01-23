import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/styles.dart';

class ShoutHeader extends StatelessWidget {
  const ShoutHeader({
    Key key,
    @required this.challenger,
    @required this.challenged,
    @required this.post,
    this.onTrailing,
  }) : super(key: key);

  final User challenger;
  final User challenged;
  final Post post;
  final VoidCallback onTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: challenger.username,
                      style: TextStyles.w600Text,
                      recognizer: TapGestureRecognizer()
                        ..onTap = (() => Navigator.push(
                            context, ProfileScreen.route(challenger.uid))),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyles.defaultText,
                    ),
                    TextSpan(
                      text: challenged.username,
                      style: TextStyles.w600Text,
                      recognizer: TapGestureRecognizer()
                        ..onTap = (() => Navigator.push(
                            context, ProfileScreen.route(challenged.uid))),
                    ),
                  ]),
                ),
                if ((post.metadata['topic'] ?? '').isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    post.metadata['topic'],
//                  '${post.owner.username} ${post.id}',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ]
              ],
            ),
          ),
          if (onTrailing != null)
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                size: 24,
              ),
              onPressed: onTrailing,
            )
        ],
      ),
    );
  }
}
