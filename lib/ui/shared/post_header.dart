import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/styles.dart';

class PostHeader extends StatelessWidget {
  final Post post;
  final VoidCallback onMorePressed;
  final VoidCallback onDisplayNameTapped;
  final VoidCallback onAvatarTapped;
  final bool canUnfollow;

  final bool isShout;

  const PostHeader(
      {Key key,
      this.onMorePressed,
      this.onDisplayNameTapped,
      @required this.post,
      this.onAvatarTapped,
      this.canUnfollow = false,
      this.isShout})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final data = post.metadata;

    final challenger = User.fromMap(data['challenger'] ?? {});
    final challenged = User.fromMap(data['challenged'] ?? {});

    return AvatarListItem(
      avatar: AvatarImage(
        url: post.owner.urls.small,
        onTap: () =>
            Navigator.push(context, ProfileScreen.route(post.owner.uid)),
      ),
      richTitle: isShout
          ? TextSpan(
              children: [
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
              ],
            )
          : null,
      title: post.owner.username,
      subtitle: isShout ? post.metadata['topic'] ?? '' : null,
      trailingWidget: IconButton(
        icon: Icon(
          Icons.more_horiz,
          size: 24,
        ),
        onPressed: () {
          onMorePressed();
          return {print('post trailing widget pressed')};
        },
      ),
      onAvatarTapped: onAvatarTapped,
      onBodyTapped: onDisplayNameTapped,
    );
  }
}
