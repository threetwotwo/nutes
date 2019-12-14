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
      padding: EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: uploader.username,
            style: TextStyles.defaultText.copyWith(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: ' $text',
            style: TextStyles.defaultText,
          ),
        ]),
      ),
    );
  }
}
