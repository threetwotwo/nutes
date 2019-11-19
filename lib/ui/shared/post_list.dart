import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

enum PostHeight { small, medium, large }

PostHeight calculatePostHeight(int charLength) {
  if (charLength < 150) {
    return PostHeight.small;
  } else if (charLength < 400) {
    return PostHeight.medium;
  } else
    return PostHeight.large;
}

double getPostAspectRatio(PostHeight postHeight) {
  return <PostHeight, double>{
    PostHeight.small: 1.4,
    PostHeight.medium: 1,
    PostHeight.large: 0.8,
  }[postHeight];
}

class PostListView extends StatefulWidget {
  final List<Post> posts;
  final bool pushNavigationEnabled;

  const PostListView({
    Key key,
    @required this.posts,
    this.pushNavigationEnabled = true,
  }) : super(key: key);

  @override
  _PostListViewState createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView>
    with AutomaticKeepAliveClientMixin<PostListView> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.posts == null ? 0 : widget.posts.length,
        itemBuilder: (context, index) {
          return PostListItem(
            post: widget.posts[index],
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

  PostListItem({
    Key key,
    this.post,
    this.shouldNavigate = true,
    this.onCommentTapped,
    this.onProfileTapped,
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

    final postHeight = calculatePostHeight(totalChars);
    final aspectRatio = getPostAspectRatio(postHeight);

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
                                      style: TextStyles.W500Text15,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = (() => Navigator.push(
                                            context,
                                            ProfileScreen.route(
                                                challenger.uid))),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: TextStyles.w300Text,
                                    ),
                                    TextSpan(
                                      text: challenged.username,
                                      style: TextStyles.W500Text15,
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
                          onMorePressed: () {},
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
                            ),
                            imageUrl: post.urls[index].medium,
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
                              builder: (context) => CommentScreen(),
                            ),
                          ),
                          controller: _controller,
                          itemCount: post.type == PostType.shout
                              ? 1
                              : post.urls.length,
                        ),
                        LikeCountBar(
                          post: post,
                        ),
                        if (post.caption.isNotEmpty)
                          Container(
                            padding: EdgeInsets.only(top: 8),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: post.owner.username,
                                  style: TextStyles.W500Text15,
                                ),
                                TextSpan(
                                  text: ' ${post.caption}',
                                  style: TextStyles.w300Text,
                                ),
                              ]),
                            ),
                          ),
//                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            TimeAgo.formatLong(post.timestamp.toDate()),
                            style: TextStyles.w300Display
                                .copyWith(fontSize: 14, color: Colors.grey),
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
                  TextSpan(
                      text: 'Liked by ',
                      style: TextStyles.W500Text15.copyWith(
                          fontWeight: FontWeight.w300)),
                  ...post.myFollowingLikes
                      .asMap()
                      .map((index, user) => MapEntry(
                          index,
                          TextSpan(
                            text: index == post.myFollowingLikes.length - 1
                                ? '${user.username} '
                                : '${user.username}, ',
                            style: TextStyles.W500Text15,
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
                        style: TextStyles.W500Text15.copyWith(
                            fontWeight: FontWeight.w300)),
                  if (stats.likeCount - post.myFollowingLikes.length > 0)
                    TextSpan(
                        text:
                            '${stats.likeCount - post.myFollowingLikes.length} ${stats.likeCount - post.myFollowingLikes.length > 1 ? 'others' : 'other '}',
                        style: TextStyles.W500Text15),
                ]),
              )
            : Text('${stats.likeCount} likes', style: TextStyles.W500Text15),
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
