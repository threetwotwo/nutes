import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/screens/edit_post_screen.dart';
import 'package:nutes/ui/shared/comment_post_list_item.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/widgets/like_count_bar.dart';
import 'package:nutes/utils/timeAgo.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/comment_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/page_viewer.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/shout_post.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nutes/ui/shared/dots_indicator.dart';
import 'avatar_list_item.dart';
import 'package:vibrate/vibrate.dart';

class PostListView extends StatefulWidget {
  final List<Post> posts;
  final bool pushNavigationEnabled;
  final Function(String) onAddComment;
  final Function(String) onUnfollow;

  const PostListView({
    Key key,
    @required this.posts,
    this.pushNavigationEnabled = true,
    this.onAddComment,
    this.onUnfollow,
  }) : super(key: key);

  @override
  _PostListViewState createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  List<Post> posts;

  @override
  void initState() {
    posts = widget.posts;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: posts == null ? 0 : posts.length,
        itemBuilder: (context, index) {
          return PostListItem(
            post: posts[index],
            onAddComment: (postId) => widget.onAddComment(postId),
            shouldNavigate: widget.pushNavigationEnabled,
            onUnfollow: (uid) {
//              setState(() {
//                posts = List.from(posts)
//                  ..removeWhere((post) => post.owner.uid == uid);
//              });
              return widget.onUnfollow(uid);
            },
          );
        });
  }
}

class PostListItem extends StatefulWidget {
  final Post post;
  final bool shouldNavigate;
  final Function onProfileTapped;
  final Function onCommentTapped;
  final Function(String) onAddComment;
  final Function(String) onUnfollow;

  PostListItem({
    Key key,
    this.post,
    this.shouldNavigate = true,
    this.onCommentTapped,
    this.onProfileTapped,
    this.onAddComment,
    this.onUnfollow,
  }) : super(key: key);

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  final _controller = PreloadPageController();

  void _navigateToProfile(BuildContext context) {
    print('nav to prof ${widget.post.owner.uid}');
    Navigator.of(context).push(ProfileScreen.route(widget.post.owner.uid));
  }

  ///Helper fields to calculate like count correctly
  ///This value will not change once set
  bool likedPost;
  bool likedShoutLeft;
  bool likedShoutRight;

  ///Flag to ensure the above field is unchanged
  bool postLikeIsInitiated = false;
  bool shoutLeftLikeIsInitiated = false;
  bool shoutRightLikeIsInitiated = false;

  Post post;

  bool isCommenting = false;

  final commentController = TextEditingController();
  final commentNode = FocusNode();

  final auth = Auth.instance;

  double biggestAspectRatio;

  _getPostComplete() async {
    print('get post compelte');

    final result = widget.post.urlBundles == null
        ? await Repo.getPostComplete(widget.post.id, widget.post.owner.uid)
        : await Repo.getPostStatsAndLikes(widget.post);

    setState(() {
      post = result;
    });
  }

  @override
  void initState() {
    post = widget.post;

    ///Get complete post if any info is incomplete
    if (post == null || post.stats == null || post.myFollowingLikes == null)
      _getPostComplete();
//    liked = post.myLikes?.didLike ?? false;

    ///Get aspect ratio for [PageViewer] from the biggest image
    ///ie. lowest aspect ratio

    if (post.type == PostType.text) {
      final aspectRatios = post.urlBundles.map((b) => b.aspectRatio).toList();
      biggestAspectRatio = aspectRatios.reduce(min);
    }

//    print(aspectRatios);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isShout = post.type == PostType.shout;

    final data = post.metadata;

    final challenger = User.fromMap(data['challenger'] ?? {});
    final challenged = User.fromMap(data['challenged'] ?? {});

    return post.stats == null || post.myFollowingLikes == null
        ? LoadingIndicator()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              isShout
                  ? Container(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: challenger.username,
                                  style: TextStyles.w600Text,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = (() => Navigator.push(context,
                                        ProfileScreen.route(challenger.uid))),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: TextStyles.defaultText,
                                ),
                                TextSpan(
                                  text: challenged.username,
                                  style: TextStyles.w600Text,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = (() => Navigator.push(context,
                                        ProfileScreen.route(challenged.uid))),
                                ),
                              ]),
                            ),
                            SizedBox(height: 3),
                            Text(
                              post.id,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : PostHeader(
                      post: post,
                      onDisplayNameTapped: () => widget.shouldNavigate
                          ? _navigateToProfile(context)
                          : null,
                      onMorePressed: () => showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            final isOwner = post.owner.uid == auth.profile.uid;
                            return CupertinoActionSheet(
                              actions: <Widget>[
                                if (isOwner)
                                  CupertinoActionSheetAction(
                                    child: Text('Delete',
                                        style:
                                            TextStyles.defaultDisplay.copyWith(
                                          color: Colors.red,
                                        )),
                                    onPressed: () {
                                      BotToast.showText(
                                        text: 'Deleted post',
                                        align: Alignment.center,
                                      );
                                    },
                                  ),
                                if (isOwner)
                                  CupertinoActionSheetAction(
                                    child: Text('Edit',
                                        style: TextStyles.defaultDisplay),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final result = await Navigator.push(
                                          context, EditPostScreen.route(post));

                                      if (result is Post) {
                                        setState(() {
                                          post = result;
                                        });
                                      }
                                      return;
                                    },
                                  ),
                                if (!isOwner) ...[
                                  CupertinoActionSheetAction(
                                    child: Text('Unfollow',
                                        style: TextStyles.defaultDisplay),
                                    onPressed: () {
                                      Repo.unfollowUser(post.owner.uid);
                                      BotToast.showText(
                                        text:
                                            'Unfollowed ${post.owner.username}',
                                        align: Alignment.center,
                                      );
                                      widget.onUnfollow(post.owner.uid);
                                      return Navigator.pop(context);
                                    },
                                  ),
                                ]
                              ],
                              cancelButton: FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel',
                                    style: TextStyles.defaultDisplay),
                              ),
                            );
                          }),
                    ),
              Divider(height: 0, thickness: 1),
              if (isShout) ...[
                StreamBuilder<DocumentSnapshot>(
                    stream: Repo.myShoutLeftLikeStream(post),
                    builder: (context, snapshot) {
                      final liked = snapshot.data?.exists;
                      if (!shoutLeftLikeIsInitiated && liked != null) {
                        likedShoutLeft = liked;
                        shoutLeftLikeIsInitiated = true;
                      }

                      return ShoutPostBubble(
                        isChallenger: true,
                        post: post,
                        stats: post.stats,
                        didLike: liked,
                        likeCount: liked == null
                            ? 0
                            : post.stats.shoutLeftLikeCount +
                                (likedShoutLeft ? 0 : 1) +
                                (liked ? 0 : -1),
                        onHeartTapped: () {
                          liked
                              ? Repo.unlikeShout(true, post)
                              : Repo.likeShout(true, post);
                        },
                      );
                    }),
                StreamBuilder<DocumentSnapshot>(
                    stream: Repo.myShoutRightLikeStream(post),
                    builder: (context, snapshot) {
//                      if (!snapshot.hasData) return SizedBox();

                      final liked = snapshot.data?.exists;
                      if (!shoutRightLikeIsInitiated && liked != null) {
                        likedShoutRight = liked;
                        shoutRightLikeIsInitiated = true;
                      }

                      return ShoutPostBubble(
                        isChallenger: false,
                        post: post,
                        stats: post.stats,
                        didLike: liked,
                        likeCount: liked == null
                            ? 0
                            : post.stats.shoutRightLikeCount +
                                (likedShoutRight ? 0 : 1) +
                                (liked ? 0 : -1),
                        onHeartTapped: () {
                          liked
                              ? Repo.unlikeShout(false, post)
                              : Repo.likeShout(false, post);
                        },
                      );
                    }),
              ],
              if (!isShout)
                AspectRatio(
                  aspectRatio: biggestAspectRatio ?? 1,
                  child: PageViewer(
                    controller: _controller,
                    length: post.urlBundles.length,
                    builder: (context, index) {
                      return FadeInImage(
                        image: NetworkImage(post.urlBundles[index].medium),
                        placeholder: NetworkImage(post.urlBundles[index].small),
                        fit: BoxFit.cover,
                      );
//                      return CachedNetworkImage(
//                        fit: BoxFit.cover,
//                        placeholder: (context, url) => Container(
//                          color: Colors.grey[100],
//                        ),
//                        imageUrl: post.urlBundles[index].medium,
//                      );
                    },
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder<DocumentSnapshot>(
                    stream: Repo.myPostLikeStream(widget.post),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return SizedBox();
                      final liked = snapshot.data.exists;
                      if (!postLikeIsInitiated) {
                        likedPost = liked;
                        postLikeIsInitiated = true;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          PostActionBar(
                            didLike: liked,
                            onHeartTapped: () async {
                              liked
                                  ? Repo.unlikePost(post)
                                  : Repo.likePost(post);
                            },
                            onCommentTapped: () =>
                                Navigator.of(context, rootNavigator: true).push(
                              CommentScreen.route(post),
                            ),
                            onSendTapped: () {
                              print('send tpped');
                            },
                            controller: _controller,
                            itemCount: post.type == PostType.shout
                                ? 1
                                : post.urlBundles.length,
                          ),
                          Visibility(
                            visible: post.stats.likeCount +
                                    (likedPost ? 0 : 1) +
                                    (liked ? 0 : -1) >
                                0,
                            child: LikeCountBar(
                              post: post,
                              likeCount: post.stats.likeCount +
                                  (likedPost ? 0 : 1) +
                                  (liked ? 0 : -1),
                            ),
                          ),

                          ///Caption
                          if (post.caption.isNotEmpty)
                            CommentPostListItem(
                              uploader: post.owner,
                              text: post.caption,
                            ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: <Widget>[
                                ///View more comments button
                                if (post.stats.commentCount > 0) ...[
                                  Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CommentScreen.route(post),
                                      ),
                                      child: Text(
                                        'View all ${post.stats.commentCount} comments',
                                        style: TextStyles.defaultText
                                            .copyWith(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      ' · ',
                                      style: TextStyles.defaultText
                                          .copyWith(color: Colors.grey),
                                    ),
                                  ),
                                ],

                                ///Add Comment Button
                                Material(
                                  color: Colors.white,
                                  child: InkWell(
                                    splashColor: Colors.white,
                                    highlightColor: Colors.grey[100],
                                    onTap: () =>
                                        widget.onAddComment(widget.post.id),
                                    child: Text(
                                      '${post.stats.commentCount > 0 ? 'A' : 'A'}dd comment',
                                      style: TextStyles.defaultText.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (post.topComments != null &&
                              post.topComments.isNotEmpty)
                            for (final c in post.topComments)
                              CommentPostListItem(
                                  uploader: c.owner, text: c.text),

                          ///Timestamp
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: Text(
                              TimeAgo.formatLong(post.timestamp.toDate()),
                              style: TextStyles.defaultText
                                  .copyWith(fontSize: 13, color: Colors.grey),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ],
          );
  }
}

class PostHeader extends StatelessWidget {
  final Post post;
  final Function onMorePressed;

  final Function onDisplayNameTapped;
  final VoidCallback onAvatarTapped;
  const PostHeader(
      {Key key,
      this.onMorePressed,
      this.onDisplayNameTapped,
      @required this.post,
      this.onAvatarTapped})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AvatarListItem(
      avatar: AvatarImage(
        url: post.owner.urls.small,
      ),
      title: post.owner.username,
      subtitle: post.id,
      trailingWidget: IconButton(
        icon: Icon(
          Icons.more_horiz,
          size: 24,
        ),
        onPressed: () {
          onMorePressed();
          return {print('post trailing widget pressed')};
        },
      ),
      onAvatarTapped: onAvatarTapped,
      onBodyTapped: onDisplayNameTapped,
    );
  }
}

class PostActionBar extends StatelessWidget {
  final Function onHeartTapped;
  final Function onCommentTapped;
  final Function onSendTapped;
  final PreloadPageController controller;
  final int itemCount;
  final bool didLike;
  const PostActionBar({
    Key key,
    this.onHeartTapped,
    this.onCommentTapped,
    this.onSendTapped,
    this.controller,
    this.itemCount,
    this.didLike,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: didLike == null
                ? SizedBox()
                : PostEngagementButtons(
                    onHeartTapped: () async {
                      Vibrate.feedback(FeedbackType.selection);
                      return onHeartTapped();
                    },
                    onCommentTapped: onCommentTapped,
                    onSendTapped: onSendTapped,
                    didLike: didLike,
                  ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DotsIndicator(
                  preloadController: controller, length: itemCount),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }
}

class PostEngagementButtons extends StatelessWidget {
  final Function onHeartTapped;
  final Function onCommentTapped;
  final Function onSendTapped;
  final bool didLike;
  const PostEngagementButtons({
    Key key,
    this.onHeartTapped,
    this.onCommentTapped,
    this.onSendTapped,
    this.didLike,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ///Try Feather Icons
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        EngagementButton(
          onTap: onHeartTapped,
          color: didLike ? Colors.red : Colors.black,
          icon: didLike ? FontAwesome.heart : FontAwesome.heart_o,
        ),
        SizedBox(width: 15),
        EngagementButton(
          onTap: onCommentTapped,
          icon: FontAwesome.comment_o,
        ),
        SizedBox(width: 15),
        EngagementButton(
          onTap: onSendTapped,
          icon: SimpleLineIcons.paper_plane,
        ),
      ],
    );
  }
}

class EngagementButton extends StatelessWidget {
  final iconSize = 24.0;
  final Color color;

  const EngagementButton({
    Key key,
    @required this.onTap,
    @required this.icon,
    this.color = Colors.black,
  }) : super(key: key);

  final Function onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: this.color,
          size: iconSize,
        ));
  }
}
