import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/comment_text.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/timeAgo.dart';

final _greyTextStyle = TextStyles.defaultText.copyWith(
  fontSize: 14,
  color: Colors.grey,
);

class CommentListItem extends StatelessWidget {
  final Comment comment;

  final Function(Comment) onReply;

  final VoidCallback onMoreReplies;

  final bool isCaption;

  final int repliesVisibleCount;

  final bool didLike;

  final VoidCallback onLike;

  final bool isLoadingMore;

  const CommentListItem({
    Key key,
    @required this.comment,
    this.onReply,
    this.isCaption = false,
    this.repliesVisibleCount = 0,
    this.onMoreReplies,
    this.didLike,
    this.onLike,
    this.isLoadingMore = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left:
              comment.parentId == 'root' || comment.parentId == null ? 0 : 40),
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
                    width: comment.parentId == 'root' ||
                            comment.parentId == null ||
                            comment.parentId.isEmpty
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
                        onLeading: (uid) => Navigator.of(context)
                            .push(ProfileScreen.route(uid)),
                        onMention: (name) {
                          print(name);
                          return Navigator.of(context)
                              .push(ProfileScreen.routeUsername(name));
                        },
                        style: TextStyles.defaultText,
                      ),
                      SizedBox(height: 4),
                      Container(
                        child: Row(
                          children: <Widget>[
                            ///Timestamp
                            Text(
                                TimeAgo.formatShort(comment.timestamp.toDate()),
                                style: _greyTextStyle),
                            if (!isCaption) ...[
                              //Like count
                              if (comment.stats.likeCount > 0) ...[
                                SizedBox(width: 16),
                                Text(
                                    '${comment.stats.likeCount} like' +
                                        '${comment.stats.likeCount > 1 ? 's' : ''}',
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
                  isCaption
                      ? LineIcons.fire
                      : didLike ? LineIcons.heart : LineIcons.heart_o,
                  color: isCaption
                      ? Colors.white
                      : isCaption
                          ? Colors.transparent
                          : didLike ? Colors.red : Colors.grey,
                  size: 14,
                ),
                onPressed: isCaption ? null : onLike,
              ),
            ],
          ),
          if (comment.stats != null &&
              comment.stats.replyCount > 0 &&
              comment.stats.replyCount - repliesVisibleCount > 0)
            Row(
              children: <Widget>[
                Container(
                  height: 1,
                  width: 40,
                  margin: EdgeInsets.only(
                      left:
                          comment.parentId == 'root' || comment.parentId == null
                              ? 48
                              : 88),
                  color: Colors.grey[300],
                ),
                InkWell(
                  onTap: () {
                    print('im tapped ${comment.id}');
                    return onMoreReplies();
                  },
                  child: Container(
//                  color: Colors.red,
                    padding: const EdgeInsets.all(8),
                    child: isLoadingMore
                        ? LoadingIndicator(padding: 2)
                        : Text(
                            'View replies (${comment.stats.replyCount - repliesVisibleCount})',
                            style: TextStyles.w600Text
                                .copyWith(color: Colors.grey, fontSize: 13),
                          ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
