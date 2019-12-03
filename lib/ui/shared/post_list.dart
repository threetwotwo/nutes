import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/screens/edit_post_screen.dart';
import 'package:nutes/ui/shared/comment_list_item.dart';
import 'package:nutes/utils/timeAgo.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/comment_screen.dart';
import 'package:nutes/ui/screens/likes_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/page_viewer.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/shout_post.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nutes/ui/shared/dots_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'avatar_list_item.dart';

class PostListView extends StatefulWidget {
  final List<Post> posts;
  final bool pushNavigationEnabled;
  final Function(String) onAddComment;

  const PostListView({
    Key key,
    @required this.posts,
    this.pushNavigationEnabled = true,
    this.onAddComment,
  }) : super(key: key);

  @override
  _PostListViewState createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.posts == null ? 0 : widget.posts.length,
        itemBuilder: (context, index) {
          return PostListItem(
            post: widget.posts[index],
            onAddComment: (postId) => widget.onAddComment(postId),
            shouldNavigate: widget.pushNavigationEnabled,
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

  PostListItem({
    Key key,
    this.post,
    this.shouldNavigate = true,
    this.onCommentTapped,
    this.onProfileTapped,
    this.onAddComment,
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

  bool didLike;

  bool didLikeChallenger = false;
  bool didLikeChallenged = false;

  Post post;

  bool isCommenting = false;

  final commentController = TextEditingController();
  final commentNode = FocusNode();

  final auth = Auth.instance;

  _getPostComplete() async {
    print('get post compelte');

    final result = widget.post.urls == null
        ? await Repo.getPostComplete(widget.post.id, widget.post.owner.uid)
        : await Repo.getPostStatsAndLikes(widget.post);

    setState(() {
      post = result;
    });
  }

  @override
  void initState() {
    post = widget.post;
    if (post == null || post.stats == null || post.myFollowingLikes == null)
      _getPostComplete();
    didLike = post.myLikes?.didLike ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (post == null || post.urls == null)
      return Container(
        padding: const EdgeInsets.all(30),
        child: Align(
            alignment: Alignment.topCenter,
            child: CupertinoActivityIndicator()),
      );

    final isShout = post.type == PostType.shout;

    final data = post.metadata;

    final challenger = User.fromMap(data['challenger'] ?? {});
    final challenged = User.fromMap(data['challenged'] ?? {});

    final String challengerText = data['challenger_text'] ?? '';
    final String challengedText = data['challenged_text'] ?? '';

    final totalChars = challengedText.length + challengerText.length;

//    final postHeight = calculatePostHeight(totalChars);

    return post.stats == null || post.myFollowingLikes == null
        ? Container(
            padding: const EdgeInsets.all(30),
            child: Align(
                alignment: Alignment.topCenter,
                child: CupertinoActivityIndicator()),
          )
        : StreamBuilder<DocumentSnapshot>(
            stream: null,
            builder: (context, snapshot) {
              if (isShout) {
                didLikeChallenger = !snapshot.hasData
                    ? false
                    : (snapshot.data.exists &&
                            snapshot.data['challenger_likes'] != null)
                        ? snapshot.data['challenger_likes'][post.id] != null
                        : false;
                didLikeChallenged = !snapshot.hasData
                    ? false
                    : (snapshot.data.exists &&
                            snapshot.data['challenged_likes'] != null)
                        ? snapshot.data['challenged_likes'][post.id] != null
                        : false;
              }

              return Column(
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
                                        ..onTap = (() => Navigator.push(
                                            context,
                                            ProfileScreen.route(
                                                challenger.uid))),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: TextStyles.defaultText,
                                    ),
                                    TextSpan(
                                      text: challenged.username,
                                      style: TextStyles.w600Text,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = (() => Navigator.push(
                                            context,
                                            ProfileScreen.route(
                                                challenged.uid))),
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
                                final isOwner =
                                    post.owner.uid == auth.profile.uid;
                                return CupertinoActionSheet(
                                  actions: <Widget>[
                                    if (isOwner)
                                      CupertinoActionSheetAction(
                                        child: Text('Delete',
                                            style: TextStyles.defaultDisplay
                                                .copyWith(
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
                                        onPressed: () => Navigator.push(context,
                                            EditPostScreen.route(post)),
                                      ),
                                    if (!isOwner) ...[
                                      CupertinoActionSheetAction(
                                        child: Text('Mute',
                                            style: TextStyles.defaultDisplay),
                                        onPressed: () {},
                                      ),
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
                    ShoutPostBubble(
                      isChallenger: true,
                      post: post,
                      stats: post.stats,
                      didLike: didLikeChallenger,
                      onHeartTapped: () {
                        setState(() {
                          didLikeChallenger = !didLikeChallenger;
                          final val = didLikeChallenger ? 1 : -1;
                          post.stats = post.stats.copyWith(
                              challengerCount:
                                  post.stats.challengerCount + val);
                        });

                        didLikeChallenger
                            ? Repo.likeShoutBubble(true, post)
                            : Repo.unlikeShoutBubble(true, post);
                      },
                    ),
                    ShoutPostBubble(
                      isChallenger: false,
                      stats: post.stats,
                      post: post,
                      didLike: didLikeChallenged,
                      onHeartTapped: () {
                        setState(() {
                          didLikeChallenged = !didLikeChallenged;
                          final val = didLikeChallenged ? 1 : -1;
                          post.stats = post.stats.copyWith(
                              challengedCount:
                                  post.stats.challengedCount + val);
                        });
                        didLikeChallenged
                            ? Repo.likeShoutBubble(false, post)
                            : Repo.unlikeShoutBubble(false, post);
                      },
                    ),
                  ],
                  if (!isShout)
                    AspectRatio(
                      aspectRatio: post.urls.first.aspectRatio ?? 1,
                      child: PageViewer(
                        controller: _controller,
                        length: post.urls.length,
                        builder: (context, index) {
//                          return Container();
                          return CachedNetworkImage(
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[100],
                              child: CircularProgressIndicator(
                                value: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                                strokeWidth: 1.0,
                              ),
                            ),
//                              placeholder: (context, url) => Image.network(
//                                post.urls[index].small,
//                                fit: BoxFit.cover,
//                              ),
                            imageUrl: post.urls[index].original,
                          );
                        },
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        PostActionBar(
                          didLike: didLike,
                          onHeartTapped: () async {
                            setState(() {
                              didLike = !didLike;

                              final val = didLike ? 1 : -1;
                              post.stats = post.stats.copyWith(
                                  likeCount: post.stats.likeCount + val);
                            });

                            didLike
                                ? Repo.likePost(post)
                                : Repo.unlikePost(post);

                            print(
                                'heart tapped, ${didLike ? 'like' : 'unlike'} '
                                'post ${post.id}');
                          },
                          onCommentTapped: () =>
                              Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                              fullscreenDialog: false,
                              builder: (context) => CommentScreen(
                                postId: post.id,
                              ),
                            ),
                          ),
                          onSendTapped: () {
                            print('send tpped');
                            BotToast.showText(
                              text: 'Unfollowed ${post.owner.username}',
                              align: Alignment.center,
                            );
                          },
                          controller: _controller,
                          itemCount: post.type == PostType.shout
                              ? 1
                              : post.urls.length,
                        ),
                        Visibility(
                          visible: post.stats.likeCount > 0,
                          child: LikeCountBar(
                            post: post,
                          ),
                        ),

                        ///Caption
                        if (post.caption.isNotEmpty)
                          CommentPostListItem(
                            uploader: post.owner,
                            text: post.caption,
                          ),

                        Row(
                          children: <Widget>[
                            ///View more comments button
                            if (post.stats.commentCount > 0) ...[
                              Material(
                                color: Colors.white,
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    CommentScreen.route(post.id),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      'View all ${post.stats.commentCount} comments',
                                      style: TextStyles.defaultText
                                          .copyWith(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '  ·  ',
                                  style: TextStyles.defaultText
                                      .copyWith(color: Colors.blueAccent[400]),
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
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Add comment',
                                    style: TextStyles.defaultText.copyWith(
                                        color:
                                            Colors.blue[900].withOpacity(0.8)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (post.topComments != null &&
                            post.topComments.isNotEmpty)
                          for (final c in post.topComments)
                            CommentPostListItem(
                                uploader: c.owner, text: c.text),

                        ///Timestamp
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            TimeAgo.formatLong(post.timestamp.toDate()),
                            style: TextStyles.defaultText
                                .copyWith(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
  }
}

class LikeCountBar extends StatelessWidget {
//  final int likeCount;

//  const LikeCountBar({Key key, this.likeCount}) : super(key: key);
  final Post post;

  const LikeCountBar({Key key, this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final stats = post.stats ?? PostStats.empty(post.id);

    return Container(
      child: GestureDetector(
        onTap: () {
          print('likes bar tapped');
          Navigator.push(context, LikeScreen.route(post));
        },
        child: post.myFollowingLikes.isNotEmpty
            ? RichText(
                text: TextSpan(children: [
                  TextSpan(text: 'Liked by ', style: TextStyles.defaultText),
                  ...post.myFollowingLikes
                      .asMap()
                      .map((index, user) => MapEntry(
                          index,
                          TextSpan(
                            text: index == post.myFollowingLikes.length - 1
                                ? '${user.username} '
                                : '${user.username}, ',
                            style: TextStyles.w600Text,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                print('tapped ${user.username}');
                                Navigator.push(
                                    context, ProfileScreen.route(user.uid));
                              },
                          )))
                      .values
                      .toList(),
                  if (stats.likeCount - post.myFollowingLikes.length > 0)
                    TextSpan(
                        text: ' and ',
                        style: TextStyles.w600Text
                            .copyWith(fontWeight: FontWeight.w300)),
                  if (stats.likeCount - post.myFollowingLikes.length > 0)
                    TextSpan(
                        text:
                            '${stats.likeCount - post.myFollowingLikes.length} ${stats.likeCount - post.myFollowingLikes.length > 1 ? 'others' : 'other '}',
                        style: TextStyles.w600Text),
                ]),
              )
            : Text('${stats.likeCount} like${stats.likeCount > 1 ? 's' : ''}',
                style: TextStyles.w600Text),
      ),
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
        url: post.owner.photoUrl,
//        padding: 5,
        showStoryIndicator: true,
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
                    onHeartTapped: onHeartTapped,
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
