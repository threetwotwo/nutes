import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/responsive.dart';

import 'package:nutes/ui/shared/avatar_image.dart';

enum StoryState { loading, none, unseen, seen }

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
//  final UserStats stats;
  final bool isOwner;
  final bool isFollowing;
  final Function onEditPressed;
  final Function onMessagePressed;
//  final bool hasStories;
  final StoryState storyState;

  final VoidCallback onAvatarPressed;
  final VoidCallback onFollowersPressed;
  final VoidCallback onFollowingsPressed;

  final VoidCallback onFollow;
  final VoidCallback onRequest;

  final bool hasRequest;

  final bool isBlocked;

  final VoidCallback onUnblock;

  const ProfileHeader({
    Key key,
    @required this.profile,
    @required this.isOwner,
//    @required this.stats,
    this.onEditPressed,
    this.onMessagePressed,
    this.isFollowing,
    this.onFollow,
//    @required this.hasStories,
    this.onAvatarPressed,
    this.onFollowersPressed,
    this.onFollowingsPressed,
    this.onRequest,
    this.storyState = StoryState.none,
    this.hasRequest = false,
    this.isBlocked = true,
    this.onUnblock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (profile == null) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
//            color: Colors.red,

            color: Colors.grey[100].withOpacity(0.3),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 5,
                child: Container(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AvatarImage(
                      storyState: storyState,
                      onTap: onAvatarPressed,
                      addStory: isOwner && storyState == StoryState.none,
                      addStoryIndicatorSize: 16,
                      spacing: 4,
                      padding: 8,
                      ringWidth: 4,
                      url: profile.user.urls.original ?? '',
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      SizedBox(height: screenAwareSize(20, context)),
                      Expanded(
                          child: Container(
                        child: profile.stats == null
                            ? SizedBox()
                            : UserStatsUI(
                                stats: profile.stats,
                                onFollowersPressed: onFollowersPressed,
                                onFollowingsPressed: onFollowingsPressed,
                              ),
                      )),
                      SizedBox(height: screenAwareSize(20, context)),
                      isFollowing && !isOwner == null
                          ? LoadingButton()
                          : isOwner
                              ? EditProfileButton(
                                  onEditPressed: onEditPressed,
                                )
                              : isBlocked
                                  ? FlatButton(
                                      color: Colors.blueAccent[400],
                                      child: Text(
                                        'Unblock',
                                        style: TextStyles.defaultText
                                            .copyWith(color: Colors.white),
                                      ),
                                      onPressed: onUnblock,
                                    )
                                  : ProfileFollowButton(
                                      hasRequest: hasRequest,
                                      user: profile.user,
                                      isFollowing: isFollowing,
                                      onMessagePressed: onMessagePressed,
                                      onRequest: onRequest,
                                      onFollow: onFollow,
                                    )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        ///Display name
        if (profile.user.displayName.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              profile.user.displayName ?? '',
              style: TextStyles.w600Text.copyWith(fontSize: 15),
              overflow: TextOverflow.fade,
            ),
          ),

        ///Bio
        if (profile.bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              child: Text(
                profile.bio ?? '',
                textAlign: TextAlign.start,
                maxLines: 10,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.defaultText
                    .copyWith(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ),
          ),
      ],
    );
  }
}

class UserStatsUI extends StatelessWidget {
  final UserStats stats;
  final VoidCallback onFollowersPressed;
  final VoidCallback onFollowingsPressed;

  const UserStatsUI(
      {Key key, this.stats, this.onFollowersPressed, this.onFollowingsPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenAwareSize(8, context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UserStatColumn(
            onTap: () => print('posts tapped'),
            title: 'posts',
            count: stats.postCount,
          ),
          SizedBox(height: screenAwareSize(8, context)),
//          Divider(height: 12),
          UserStatColumn(
            onTap: onFollowersPressed,
            title: 'followers',
            count: stats.followerCount,
          ),
          SizedBox(height: screenAwareSize(8, context)),
//          Divider(height: 12),
          UserStatColumn(
            onTap: onFollowingsPressed,
            title: 'following',
            count: stats.followingCount,
          ),
        ],
      ),
    );
  }
}

class UserStatColumn extends StatelessWidget {
  final int count;
  final String title;
  final Function onTap;

  const UserStatColumn({Key key, this.count, this.title, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$count',
            textAlign: TextAlign.start,
            style: TextStyles.large600Display.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: ColorStyles.darkPurple),
          ),
          Text(
            '$title',
            textAlign: TextAlign.start,
            style: TextStyles.defaultText.copyWith(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileFollowButton extends StatelessWidget {
  final bool isFollowing;
  final Function onMessagePressed;
//  final Function onUnfollowPressed;
  final Function onFollow;
  final VoidCallback onRequest;
  final User user;
  final bool hasRequest;

  const ProfileFollowButton({
    Key key,
    this.onMessagePressed,
    this.isFollowing,
    this.onFollow,
    @required this.user,
    this.onRequest,
    this.hasRequest,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
//    final hasRequest = user.hasRequestedFollow == true;

    return Row(
      children: <Widget>[
        Expanded(
          child: FollowButtonExtended(
            isRequested: hasRequest,
            isFollowing: isFollowing,
            onRequest: onRequest,
            onFollow: onFollow,
          ),
        ),
        if (!hasRequest) SizedBox(width: 5),
        if (!hasRequest)
          MessageButton(
            onMessagePressed: onMessagePressed,
            isFollowing: isFollowing,
          )
      ],
    );
  }
}

class LoadingButton extends StatelessWidget {
  final Function onFollowPressed;

  const LoadingButton({Key key, this.onFollowPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SoftBorderedButton(
      borderColor: Colors.grey[300],
      child: Text(
        'Loading',
        style: TextStyles.w600Text.copyWith(
            color: Colors.grey,
            fontSize: defaultSize(15, context, defaultTo: 12)),
      ),
    );
  }
}

class EditProfileButton extends StatelessWidget {
  final Function onEditPressed;

  const EditProfileButton({Key key, this.onEditPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SoftBorderedButton(
      borderColor: Colors.grey[300],
      onPressed: onEditPressed,
      child: Text(
        'Edit profile',
        style: TextStyles.w600Text.copyWith(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}

class MessageButton extends StatelessWidget {
  final Function onMessagePressed;
  final bool isFollowing;

  const MessageButton({Key key, this.onMessagePressed, this.isFollowing})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SoftBorderedButton(
      backgroundColor: isFollowing ? Colors.blueAccent[400] : Colors.white,
      onPressed: onMessagePressed,
      borderColor: Colors.blueAccent[400],
      child: Center(
          child: Icon(
        SimpleLineIcons.paper_plane,
        color: isFollowing ? Colors.white : Colors.blueAccent[400],
        size: 20,
      )),
    );
  }
}
