import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';

import 'avatar_image.dart';

class StoryAvatar extends StatelessWidget {
  final User user;
  final bool isFinished;

  final bool isEmpty;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  final String heroTag;
//  final UStoryState storyState;

  final auth = Auth.instance;

  StoryAvatar({
    Key key,
    @required this.isFinished,
    this.isEmpty = false,
    @required this.user,
    @required this.onTap,
    this.onLongPress,
    this.heroTag,
//      this.storyState,
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
                  padding: const EdgeInsets.all(2.0),
                  child: AvatarImage(
                    storyState: UStoryState.seen,
                    addStoryIndicatorSize: 7,
                    heroTag: user.uid,
                    url: user.photoUrl,
                    spacing: 2,
                    showStoryIndicator: !isFinished,
                    addStory: user.uid == auth.profile.uid && isEmpty ?? false,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
//              color: Colors.grey,
              child: Text(
                user.uid == auth.profile.uid ? 'Your Story' : user.username,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: user.uid == auth.profile.uid
                        ? Colors.grey
                        : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
