import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/styles.dart';

class CommentPostListItem extends StatelessWidget {
  final User uploader;
  final String text;

  const CommentPostListItem({
    Key key,
    @required this.uploader,
    @required this.text,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: uploader.username,
            style: TextStyles.W500Text15,
          ),
          TextSpan(
            text: ' $text',
            style: TextStyles.w300Text,
          ),
        ]),
      ),
    );
  }
}
