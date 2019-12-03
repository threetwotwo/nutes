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

  const CommentListItem({Key key, @required this.comment, this.onReply})
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
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
                      url: comment.owner.photoUrl,
                      spacing: 0,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CommentText(
                  uid: comment.owner.uid,
                  leading: TextSpan(
                    text: comment.owner.username,
                  ),
                  text: comment.text,
                  onOpen: (uid) =>
                      Navigator.of(context).push(ProfileScreen.route(uid)),
                  onTagClick: (tag) => print(tag),
                  onMention: (name) {
                    print(name);
                    return Navigator.of(context)
                        .push(ProfileScreen.routeUsername(name));
                  },
                  style: TextStyles.defaultText,
                ),
              ),
              IconButton(
                  icon: Icon(
                    LineIcons.heart_o,
                    color: Colors.grey,
                    size: 14,
                  ),
                  onPressed: () {
                    print('liked comment');
                  }),
            ],
          ),
          Container(
//            color: Colors.red,
            child: Row(
              children: <Widget>[
                SizedBox(width: 50),
                Text(TimeAgo.formatShort(comment.timestamp.toDate()),
                    style: _greyTextStyle),
                if (comment.stats?.likeCount ?? 0 > 0) ...[
                  SizedBox(width: 20),
                  Text('${comment.stats?.likeCount ?? 0} likes',
                      style:
                          _greyTextStyle.copyWith(fontWeight: FontWeight.w400)),
                ],
                SizedBox(width: 20),
                Material(
                  child: InkWell(
                    onTap: () => onReply(comment),
                    child: Text('Reply',
                        style: _greyTextStyle.copyWith(
                            fontWeight: FontWeight.w400)),
                  ),
                ),
//                Text(comment.id ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
