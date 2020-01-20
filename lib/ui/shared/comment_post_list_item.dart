import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/comment_text.dart';
import 'package:nutes/ui/shared/styles.dart';

class CommentPostListItem extends StatelessWidget {
  final User uploader;
  final String text;
  final VoidCallback onTap;

  const CommentPostListItem({
    Key key,
    @required this.uploader,
    @required this.text,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        width: MediaQuery.of(context).size.width,

        padding: EdgeInsets.symmetric(vertical: 4),
        child: CommentText(
          uid: uploader.uid,
          leading: TextSpan(
            text: uploader.username,
            style: TextStyles.defaultText.copyWith(fontWeight: FontWeight.w600),
          ),
          text: text,
          style: TextStyles.defaultText,
          onLeading: (val) => Navigator.push(context, ProfileScreen.route(val)),
          onMention: (val) =>
              Navigator.push(context, ProfileScreen.routeUsername(val)),
//        onTagClick: (val) => print('on tag $val'),
        ),
//      child: RichText(
//        text: TextSpan(children: [
//          TextSpan(
//            text: uploader.username,
//            style: TextStyles.defaultText.copyWith(fontWeight: FontWeight.w600),
//          ),
//          TextSpan(
//            text: ' $text',
//            style: TextStyles.defaultText,
//          ),
//        ]),
//      ),
      ),
    );
  }
}
