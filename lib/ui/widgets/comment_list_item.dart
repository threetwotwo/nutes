import 'package:flutter/material.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nutes/utils/smart_text.dart';

final _greyTextStyle = TextStyles.w300Text.copyWith(
  fontSize: 13,
  color: Colors.grey,
);

class CommentListItem extends StatelessWidget {
  final Comment comment;

  const CommentListItem({Key key, @required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AvatarImage(
                url: comment.uploader.photoUrl,
                spacing: 0,
              ),
            ),
          ),
          Flexible(
            flex: 10,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
//                        RichText(
//                          text: TextSpan(
//                            style: TextStyles.medium300Text,
//                            children: [
//                              TextSpan(
//                                  text: comment.uploader.username,
//                                  style: TextStyles.medium600Text),
//                              TextSpan(text: ' '),
//                              //TODO: format with clickable links eg.
//                              // shoutouts/hastags
//                              TextSpan(text: comment.text),
//                            ],
//                          ),
//                          overflow: TextOverflow.ellipsis,
//                        ),
                        SmartText(
                          leading: TextSpan(
                            text: comment.uploader.username,
                          ),
                          text: comment.text,
                          onTagClick: (tag) => print(tag),
                          style: TextStyles.w300Text,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Text('11h', style: _greyTextStyle),
                            SizedBox(width: 20),
                            Text('9 likes',
                                style: _greyTextStyle.copyWith(
                                    fontWeight: FontWeight.w500)),
                            SizedBox(width: 20),
                            Text('Reply',
                                style: _greyTextStyle.copyWith(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: IconButton(
                    icon: Icon(
                      MaterialCommunityIcons.heart_outline,
                      color: Colors.grey,
                    ),
                    onPressed: () {}),
              )),
        ],
      ),
    );
  }
}
