import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nutes/ui/shared/dots_indicator.dart';
import 'package:nutes/ui/widgets/post_action_button.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:vibrate/vibrate.dart';

class PostActionBar extends StatelessWidget {
  final VoidCallback onHeartTapped;
  final VoidCallback onCommentTapped;
  final VoidCallback onSendTapped;
  final VoidCallback onDoodle;
  final PreloadPageController controller;
  final int itemCount;
  final bool didLike;
  const PostActionBar({
    Key key,
    this.onHeartTapped,
    this.onCommentTapped,
    this.onSendTapped,
    this.controller,
    this.itemCount,
    this.didLike,
    this.onDoodle,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: didLike == null
                ? SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      PostActionButton(
                        onTap: () async {
                          Vibrate.feedback(FeedbackType.selection);
                          return onHeartTapped();
                        },
                        color: didLike ? Colors.red : Colors.black,
                        icon: didLike ? FontAwesome.heart : FontAwesome.heart_o,
                      ),
//                      SizedBox(width: 15),
                      PostActionButton(
                        onTap: onCommentTapped,
                        icon: FontAwesome.comment_o,
                      ),
//                      SizedBox(width: 15),
                      PostActionButton(
                        onTap: onSendTapped,
                        icon: SimpleLineIcons.paper_plane,
                      ),
                    ],
                  ),
//                : PostEngagementButtons(
//                    onHeartTapped: () async {
//                      Vibrate.feedback(FeedbackType.selection);
//                      return onHeartTapped();
//                    },
//                    onCommentTapped: onCommentTapped,
//                    onSendTapped: onSendTapped,
//                    didLike: didLike,
//                  ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DotsIndicator(
                  preloadController: controller, length: itemCount),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerRight,
//              color: Colors.green[100],
              child: PostActionButton(
                onTap: onDoodle,
                icon: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
