import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/ui/screens/likes_screen.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/styles.dart';

class LikeCountBar extends StatelessWidget {
  final Post post;
  final int likeCount;

  const LikeCountBar({Key key, this.post, this.likeCount}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          print('likes bar tapped');
          Navigator.push(context, LikeScreen.route(post));
        },
        child: post.myFollowingLikes.isNotEmpty
            ? RichText(
                text: TextSpan(children: [
                  TextSpan(text: 'Liked by ', style: TextStyles.defaultText),
                  ...post.myFollowingLikes
                      .asMap()
                      .map((index, user) => MapEntry(
                          index,
                          TextSpan(
                            text: index == post.myFollowingLikes.length - 1
                                ? '${user.username} '
                                : '${user.username}, ',
                            style: TextStyles.w600Text,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                print('tapped ${user.username}');
                                Navigator.push(
                                    context, ProfileScreen.route(user.uid));
                              },
                          )))
                      .values
                      .toList(),
                  if (likeCount - post.myFollowingLikes.length > 0)
                    TextSpan(
                        text: ' and ',
                        style: TextStyles.w600Text
                            .copyWith(fontWeight: FontWeight.w300)),
                  if (likeCount - post.myFollowingLikes.length > 0)
                    TextSpan(
                        text:
                            '${likeCount - post.myFollowingLikes.length} ${likeCount - post.myFollowingLikes.length > 1 ? 'others' : 'other '}',
                        style: TextStyles.w600Text),
                ]),
              )
            : Text('$likeCount like${likeCount > 1 ? 's' : ''}',
                style: TextStyles.w600Text),
      ),
    );
  }
}
