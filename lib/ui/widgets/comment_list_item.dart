import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/comment_text.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/timeAgo.dart';

final _greyTextStyle = TextStyles.defaultText.copyWith(
  fontSize: 14,
  color: Colors.grey,
);

class CommentListItem extends StatelessWidget {
  final Comment comment;

  final Function(Comment) onReply;

  final bool isCaption;

  const CommentListItem(
      {Key key, @required this.comment, this.onReply, this.isCaption = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: comment.parentId == null || comment.parentId.isEmpty ? 0 : 40),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: comment.parentId == null || comment.parentId.isEmpty
                        ? 48
                        : 44,
                    child: AvatarImage(
                      onTap: () => Navigator.of(context)
                          .push(ProfileScreen.route(comment.owner.uid)),
                      url: comment.owner.urls.small,
                      spacing: 0,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CommentText(
                        uid: comment.owner.uid,
                        leading: TextSpan(
                          text: comment.owner.username,
                        ),
                        text: comment.text,
                        onOpen: (uid) => Navigator.of(context)
                            .push(ProfileScreen.route(uid)),
                        onTagClick: (tag) => print(tag),
                        onMention: (name) {
                          print(name);
                          return Navigator.of(context)
                              .push(ProfileScreen.routeUsername(name));
                        },
                        style: TextStyles.defaultText,
                      ),
                      SizedBox(height: 4),
                      Container(
//            color: Colors.red,
                        child: Row(
                          children: <Widget>[
//                SizedBox(width: 48),

                            ///Timestamp
                            Text(
                                TimeAgo.formatShort(comment.timestamp.toDate()),
                                style: _greyTextStyle),
                            if (!isCaption) ...[
                              ///Like count
                              if (comment.stats?.likeCount ?? 0 > 0) ...[
                                SizedBox(width: 16),
                                Text('${comment.stats?.likeCount ?? 0} likes',
                                    style: _greyTextStyle.copyWith(
                                        fontWeight: FontWeight.w400)),
                              ],
                              SizedBox(width: 16),

                              ///Reply button
                              Material(
                                color: Colors.white,
                                child: InkWell(
                                  onTap: () => onReply(comment),
                                  child: Text('Reply',
                                      style: _greyTextStyle.copyWith(
                                          fontWeight: FontWeight.w400)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                  icon: Icon(
                    LineIcons.heart_o,
                    color: isCaption ? Colors.white : Colors.grey,
                    size: 14,
                  ),
                  onPressed: isCaption
                      ? null
                      : () {
                          print('liked comment');
                        }),
            ],
          ),
//          Container(
////            color: Colors.red,
//            child: Row(
//              children: <Widget>[
////                SizedBox(width: 48),
//
//                ///Timestamp
//                Text(TimeAgo.formatShort(comment.timestamp.toDate()),
//                    style: _greyTextStyle),
//                if (!isCaption) ...[
//                  ///Like count
//                  if (comment.stats?.likeCount ?? 0 > 0) ...[
//                    SizedBox(width: 16),
//                    Text('${comment.stats?.likeCount ?? 0} likes',
//                        style: _greyTextStyle.copyWith(
//                            fontWeight: FontWeight.w400)),
//                  ],
//                  SizedBox(width: 16),
//
//                  ///Reply button
//                  Material(
//                    color: Colors.white,
//                    child: InkWell(
//                      onTap: () => onReply(comment),
//                      child: Text('Reply',
//                          style: _greyTextStyle.copyWith(
//                              fontWeight: FontWeight.w400)),
//                    ),
//                  ),
//                ],
//              ],
//            ),
//          ),
        ],
      ),
    );
  }
}
