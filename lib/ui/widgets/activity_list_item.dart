import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/activity.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/ui/screens/post_detail_screen.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/shout_post.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/timeAgo.dart';

class ActivityListItem extends StatelessWidget {
  final Activity activity;

  const ActivityListItem({Key key, @required this.activity}) : super(key: key);

  Future _goToPost(BuildContext context) {
    return Navigator.push(
        context,
        PostDetailScreen.route(null,
            postId: activity.post.id, ownerId: activity.activiyPeer.uid));
  }

  @override
  Widget build(BuildContext context) {
    final activityOwner = activity.activityOwner;
    final activityPeer = activity.activiyPeer;

    final ownerSpan = TextSpan(
        text: activityOwner.username + ' ',
        style: TextStyles.w500Text,
        recognizer: TapGestureRecognizer()
          ..onTap = () =>
              Navigator.push(context, ProfileScreen.route(activityOwner.uid)));

    final timeAgoSpan = TextSpan(
        text: ' ' + TimeAgo.formatShort(activity.timestamp.toDate()),
        style: TextStyles.w300Text.copyWith(color: Colors.grey));

    TextSpan activitySpan;

    TextSpan peerSpan;

    switch (activity.activityType) {
      case ActivityType.post_like:
        activitySpan =
            TextSpan(text: 'liked' + ' ', style: TextStyles.defaultText);
        peerSpan = TextSpan(
          children: [
            TextSpan(
                text: activityPeer.uid == FirestoreService.ath.uid
                    ? 'your '
                    : activityPeer.username + "'s ",
                style: TextStyles.w500Text),
            TextSpan(text: 'post.', style: TextStyles.defaultText),
          ],
        );
        break;
      case ActivityType.comment_like:
        // TODO: Handle this case.
        activitySpan =
            TextSpan(text: 'liked' + ' ', style: TextStyles.defaultText);
        peerSpan = TextSpan(children: [
          TextSpan(
            text: activityPeer.uid == FirestoreService.ath.uid
                ? 'your '
                : activityPeer.username + "'s ",
            style: TextStyles.w500Text,
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.push(
                  context, ProfileScreen.route(activityPeer.uid)),
          ),
          TextSpan(text: 'post.', style: TextStyles.defaultText),
        ]);

        break;
      case ActivityType.follow:
        activitySpan = TextSpan(
            text: 'started following' + ' ', style: TextStyles.defaultText);
        peerSpan = TextSpan(children: [
          TextSpan(
            text: activityPeer.uid == FirestoreService.auth.uid
                ? 'you'
                : activityPeer.username + '.',
            style: TextStyles.w500Text,
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.push(
                  context, ProfileScreen.route(activityPeer.uid)),
          ),
        ]);

        break;
    }

    return AvatarListItem(
      onTrailingWidgetPressed: () => _goToPost(context),
      onBodyTapped: () => _goToPost(context),
      trailingFlexFactor: 2,
      avatar: AvatarImage(
        onTap: () => Navigator.push(
            context, ProfileScreen.route(activity.activityOwner.uid)),
        url: activity.activityOwner.urls.small,
      ),
      richTitle: TextSpan(children: [
        ownerSpan,
        activitySpan,
        peerSpan,
        timeAgoSpan,
      ]),
      trailingWidget: activity.activityType == ActivityType.post_like
          ? Container(
              width: 64,
              height: 64,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey[200])),
              child: activity.post.type == PostType.text
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: activity.post.urlBundles.first.small,
                    )
                  : activity.post.type == PostType.shout
                      ? Wrap(
                          runSpacing: 3,
                          children: <Widget>[
                            GridShoutBubble(
                              data: activity.post.metadata,
                              isChallenger: true,
                              avatarSize: 10,
                              fontSize: 5,
                            ),
                            GridShoutBubble(
                              data: activity.post.metadata,
                              isChallenger: false,
                              avatarSize: 10,
                              fontSize: 5,
                            ),
                          ],
                        )
                      : SizedBox(),
            )
          : SizedBox(),
    );
  }
}
