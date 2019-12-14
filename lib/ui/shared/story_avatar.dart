import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/profile_header.dart';

import 'avatar_image.dart';

class StoryAvatar extends StatelessWidget {
  final User user;

  final bool isEmpty;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  final bool isOwner;

  final StoryState storyState;

  StoryAvatar({
    Key key,
    this.isEmpty = false,
    @required this.user,
    @required this.onTap,
    this.onLongPress,
    this.isOwner = false,
    this.storyState = StoryState.none,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 88,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: AvatarImage(
                    addStoryIndicatorSize: 7,
                    url: isOwner
                        ? Auth.instance.profile.user.urls.small
                        : user.urls.small,
                    storyState: storyState,
                    addStory: isOwner && isEmpty ?? false,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              child: Text(
                isOwner ? 'Your Story' : user.username,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.defaultText
                    .copyWith(color: isOwner ? Colors.grey : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
