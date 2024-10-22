import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/events/events.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/models/doodle.dart';
import 'package:nutes/core/services/events.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/ui/screens/edit_post_screen.dart';
import 'package:nutes/ui/screens/send_post_screen.dart';
import 'package:nutes/ui/shared/comment_post_list_item.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/post_header.dart';
import 'package:nutes/ui/shared/toast_message.dart';
import 'package:nutes/ui/widgets/doodle_editor.dart';
import 'package:nutes/ui/widgets/doodle_page_view.dart';
import 'package:nutes/ui/widgets/like_count_bar.dart';
import 'package:nutes/ui/widgets/post_action_bar.dart';
import 'package:nutes/utils/icon_shadow.dart';
import 'package:nutes/utils/painter.dart';
import 'package:nutes/utils/timeAgo.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/comment_screen.dart';
import 'package:nutes/ui/shared/page_viewer.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/shout_post.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:vibrate/vibrate.dart';

class PostListView extends StatelessWidget {
  final List<Post> posts;
  final bool pushNavigationEnabled;
  final Function(Post) onAddComment;
  final Function(String) onUnfollow;
  final VoidCallback onDoodleStart;
  final VoidCallback onDoodleEnd;
  final VoidCallback onDoodleShow;
  final bool showEllipsis;

  const PostListView({
    Key key,
    @required this.posts,
    this.pushNavigationEnabled = true,
    this.onAddComment,
    this.onUnfollow,
    this.onDoodleStart,
    this.onDoodleEnd,
    this.onDoodleShow,
    this.showEllipsis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: posts == null ? 0 : posts.length,
        itemBuilder: (context, index) {
          return PostListItem(
            post: posts[index],
            onAddComment: (post) => onAddComment(posts[index]),
            shouldNavigate: pushNavigationEnabled,
            onUnfollow: (uid) => onUnfollow(uid),
            onDoodleStart: onDoodleStart,
            onDoodleEnd: onDoodleEnd,
          );
        });
  }
}

class PostListItem extends StatefulWidget {
  final Post post;
  final bool shouldNavigate;
  final VoidCallback onProfileTapped;
  final VoidCallback onCommentTapped;
  final Function(Post) onAddComment;
  final Function(String) onUnfollow;
  final VoidCallback onDoodleStart;
  final VoidCallback onDoodleEnd;

  PostListItem({
    Key key,
    this.post,
    this.shouldNavigate = true,
    this.onCommentTapped,
    this.onProfileTapped,
    this.onAddComment,
    this.onUnfollow,
    this.onDoodleStart,
    this.onDoodleEnd,
  }) : super(key: key);

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem>
    with SingleTickerProviderStateMixin {
  final _controller = PreloadPageController();

  double _heartOpacity = 0.0;

  bool _isDoodling = false;

  PainterController _painterController;

  final cache = LocalCache.instance;

  List<Doodle> _doodles = [];

  bool _showDoodle = false;

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(ProfileScreen.route(widget.post.owner.uid));
  }

  ///Helper fields to calculate like count correctly
  ///This value will not change once set
  bool _likedPost;
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

  final auth = FirestoreService.ath;

  double biggestAspectRatio;

  Animation _heartAnimation;
  AnimationController _heartAnimationController;

  bool hasError = false;

  _initPainter() {
    _painterController = PainterController()
      ..drawColor = Colors.black
      ..backgroundColor = Colors.transparent
      ..thickness = 4.0;
  }

  _initHeartAnimation() {
    _heartAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _heartAnimation = Tween(begin: 16.0, end: 80.0).animate(
      CurvedAnimation(
          curve: Curves.elasticInOut, parent: _heartAnimationController),
    );
  }

  bool _doodleUploadIsFinished = false;
  bool _doodleUploadIsInProgress = false;

  Future<void> _showDoodleUploadFinished() async {
    _showDoodleUploadInProgress(false);

    await Future.delayed(Duration(milliseconds: 100));

    setState(() {
      _doodleUploadIsFinished = true;
    });

    await Future.delayed(Duration(milliseconds: 3000));

    return setState(() {
      _doodleUploadIsFinished = false;
    });
  }

  Future<void> _showDoodleUploadInProgress(bool inProgress) async {
    return setState(() {
      _doodleUploadIsInProgress = inProgress;
    });
  }

//  void _endDoodles() {
//    setState(() {
//      _showDoodle = false;
//    });
//
//    return;
//  }

  Future<void> _getDoodles() async {
    if (_showDoodle) {
      return;
    }

    setState(() {
      _showDoodle = true;
    });
    final result = await Repo.getDoodles(postId: widget.post.id);
    setState(() {
      _doodles = result;
    });
  }

  _getPostComplete() async {
    if (widget.post == null) {
      setState(() {
        hasError = true;
      });
      return;
    }

    print('get post compelte');

    final result = widget.post.urlBundles == null
        ? await Repo.getPostComplete(widget.post.id, widget.post.owner.uid)
        : await Repo.getPostStatsAndLikes(widget.post);

    setState(() {
      post = result;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _heartAnimationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initPainter();
    _initHeartAnimation();

    post = widget.post;

    ///Get complete post if any info is incomplete
    if (post == null || post.stats == null || post.myFollowingLikes == null)
      _getPostComplete();

    ///Get aspect ratio for [PageViewer] from the biggest image
    ///ie. lowest aspect ratio

//    if (post.type == PostType.text) {
//      final aspectRatios = post.urlBundles.map((b) => b.aspectRatio).toList();
//      biggestAspectRatio = aspectRatios.reduce(min);
//    }

    ///like stream
    if (post != null)
      Repo.myPostLikeStream(post).listen((data) {
        setState(() {
          if (_likedPost == null) _likedPost = data.data != null;
          postLiked = data.data != null;
        });
      });
    super.initState();
  }

  bool postLiked;

  @override
  Widget build(BuildContext context) {
    if (hasError) return EmptyIndicator('This post has been deleted.');

    final isShout = post.type == PostType.shout;

    final data = post.metadata;

    return post.stats == null || post.myFollowingLikes == null
        ? LoadingIndicator()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ///Header
              PostHeader(
                isShout: isShout,
                post: post,
                onDisplayNameTapped: () =>
                    widget.shouldNavigate ? _navigateToProfile(context) : null,
                onMorePressed: () => showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      final isOwner = post.owner.uid == auth.uid;
                      return CupertinoActionSheet(
                        actions: <Widget>[
                          if (isOwner)
                            CupertinoActionSheetAction(
                              child: Text('Delete',
                                  style: TextStyles.defaultDisplay.copyWith(
                                    color: Colors.red,
                                  )),
                              onPressed: () async {
                                BotToast.showText(
                                  text: 'Deleting post',
                                  align: Alignment.center,
                                );
                                await Repo.deletePost(post.id);
                                BotToast.showText(
                                  text: 'Deleted',
                                  align: Alignment.center,
                                );
                                eventBus.fire(PostDeleteEvent(post.id));

                                Navigator.popUntil(context, (r) => r.isFirst);

                                return;
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
                                  text: 'Unfollowed ${post.owner.username}',
                                  align: Alignment.center,
                                );
                                widget.onUnfollow(post.owner.uid);
                                return Navigator.pop(context);
                              },
                            ),
                          ],
                          if (!isOwner) ...[
                            CupertinoActionSheetAction(
                              child: Text('Report',
                                  style: TextStyles.defaultDisplay),
                              onPressed: () async {
//                                      Repo.unfollowUser(post.owner.uid);
//                                      BotToast.showText(
//                                        text:
//                                        'Unfollowed ${post.owner.username}',
//                                        align: Alignment.center,
//                                      );
                                final type = await showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => CupertinoActionSheet(
                                    title: const Text(
                                        'Why do you want to report this post?'),
                                    actions: <Widget>[
                                      CupertinoActionSheetAction(
                                        child: Text("It's spam",
                                            style: TextStyles.defaultDisplay),
                                        onPressed: () {
                                          Navigator.pop(context, 'spam');
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text("It's Inappropriate",
                                            style: TextStyles.defaultDisplay),
                                        onPressed: () {
                                          Navigator.pop(
                                              context, 'inappropriate');
                                        },
                                      )
                                    ],
                                    cancelButton: FlatButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel',
                                          style: TextStyles.defaultDisplay),
                                    ),
                                  ),
                                );

                                ///DO nothing if cancelled
                                if (type != null && type is String) {
                                  Repo.reportPost(post, type).whenComplete(() =>
                                      eventBus.fire(PostDeleteEvent(post.id)));

                                  BotToast.showText(
                                      text:
                                          'Thank you for taking the time to report',
                                      align: Alignment.center);
                                }

                                return Navigator.pop(context);
                              },
                            ),
                          ]
                        ],
                        cancelButton: FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child:
                              Text('Cancel', style: TextStyles.defaultDisplay),
                        ),
                      );
                    }),
              ),
              Divider(height: 0, thickness: 1),

              ///Content
              GestureDetector(
//                onLongPress: () {
//                  _endDoodles();
//                },
                onTap: () {
                  setState(() {
                    _doodleUploadIsInProgress = false;
                    _doodleUploadIsFinished = false;
                  });
                  _getDoodles();
                },
                onDoubleTap: () async {
                  if (_heartAnimationController.isAnimating) return;

                  Vibrate.feedback(FeedbackType.selection);

                  Repo.likePost(post);

                  _heartAnimationController.forward();
                  setState(() {
                    _heartOpacity = 1.0;
                  });
                  await Future.delayed(Duration(milliseconds: 1600));
                  setState(() {
                    _heartOpacity = 0.0;
                  });
                  _heartAnimationController.reset();
                },
                child: Stack(
                  children: <Widget>[
                    if (isShout)
                      Column(
                        children: <Widget>[
                          StreamBuilder<DocumentSnapshot>(
                              stream: Repo.myShoutLeftLikeStream(post),
                              builder: (context, snapshot) {
                                final liked = snapshot.data?.exists;
                                if (!shoutLeftLikeIsInitiated &&
                                    liked != null) {
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
                                if (!shoutRightLikeIsInitiated &&
                                    liked != null) {
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
                      ),
                    if (!isShout)
                      AspectRatio(
                        aspectRatio: post.biggestAspectRatio ?? 1,
                        child: PageViewer(
                          controller: _controller,
                          length: post.urlBundles.length,
                          builder: (context, index) {
//                      return FadeInImage(
//                        image: NetworkImage(post.urlBundles[index].medium),
//                        placeholder: NetworkImage(post.urlBundles[index].small),
//                        fit: BoxFit.cover,
//                      );
                            return CachedNetworkImage(
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                              ),
                              imageUrl: post.urlBundles[index].medium,
                            );
                          },
                        ),
                      ),

                    ///Heart Double Tap
                    Positioned.fill(
                      child: AnimatedBuilder(
                          animation: _heartAnimationController,
                          builder: (context, snapshot) {
                            return AnimatedOpacity(
                              opacity: _heartOpacity,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.bounceInOut,
                              child: Center(
                                child: IconShadow(
                                  Icon(
                                    LineIcons.heart,
                                    color: Colors.white,
                                    size: _heartAnimation.value,
                                  ),
                                  shadowColor: Colors.black87,
                                ),
                              ),
                            );
                          }),
                    ),

                    ///Doodle image
                    if (_showDoodle && _doodles.isNotEmpty)
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: _doodles.isNotEmpty ? 1 : 0,
                          duration: Duration(milliseconds: 400),
                          child: DoodlePageView(
                            doodles: _doodles,
                            isVisible: _showDoodle,
                            onError: () {
                              setState(() {
                                _showDoodle = false;
                                _doodles = [];
                              });
                            },
                            onFinish: () {
                              print('on finish show doodle');
                              return setState(() {
                                _showDoodle = false;
                              });
                            },
                          ),
                        ),
                      ),

                    ///Upload finished message
                    if (_doodleUploadIsFinished || _doodleUploadIsInProgress)
                      Positioned.fill(
                        child: Center(
                            child: ToastMessage(
                          title: _doodleUploadIsInProgress
                              ? 'Sending'
                              : 'Tap to see',
                        )),
                      ),

                    ///Doodler
                    if (_isDoodling)
                      Positioned.fill(
                          child: DoodleEditor(
                        onColor: (val) => _painterController.drawColor = val,
                        isDoodling: _isDoodling,
                        controller: _painterController,
                        onFinish: (file) async {
                          if (file == null)
                            return setState(() {
                              _isDoodling = false;
                            });
                          ;

                          _showDoodleUploadInProgress(true);

                          setState(() {
                            _isDoodling = false;
                          });
                          await Repo.uploadDoodle(postId: post.id, file: file);

                          print('post doodle upload finish');
                          _showDoodleUploadFinished();
                          return;
                        },
                      )
//                        child: Visibility(
//                          visible: _isDoodling,
//                          child: Container(
//                            color: Colors.grey[50].withOpacity(0.6),
//                            child: Painter(
//                              painterController: _painterController,
//                              onFinish: () async {
//                                print('on finished');
//                                final png =
//                                    await _painterController.finish().toPNG();
//
//                                final Directory systemTempDir =
//                                    Directory.systemTemp;
//
//                                String fileName =
//                                    DateTime.now().toIso8601String();
//
//                                final file = await File(
//                                        '${systemTempDir.path}/$fileName.png')
//                                    .create();
//
////                                    await File.fromRawPath(png);
//                                await file.writeAsBytes(png);
//
//                                Repo.uploadDoodle(postId: post.id, file: file);
//
//                                setState(() {
//                                  _isDoodling = false;
//                                  widget.onDoodleEnd();
//                                });
//                              },
//                            ),
//                          ),
//                        ),
                          ),
                  ],
                ),
              ),

              ///Action Buttons

              (postLiked == null)
                  ? SizedBox()
                  : Column(
                      children: <Widget>[
                        PostActionBar(
                          didLike: postLiked,
                          onHeartTapped: () async {
                            print('heart tapped for post ${post.id}');

                            postLiked
                                ? Repo.unlikePost(post)
                                : Repo.likePost(post);

                            setState(() {
                              postLiked = !postLiked;
                            });
                          },
                          onCommentTapped: () async {
                            _onCommentTapped();
                          },
                          onSendTapped: () =>
                              Navigator.of(context, rootNavigator: true)
                                  .push(SendPostScreen.route(post)),
                          onDoodle: () async {
                            _painterController.clear();

                            if (_showDoodle) {
                              setState(() {
                                _showDoodle = false;
                              });

                              return;
                            }

                            if (_isDoodling) {
                              setState(() {
                                _isDoodling = false;
                              });
                              return;
                            } else {
                              setState(() {
                                _isDoodling = true;
                                _painterController = PainterController()
                                  ..drawColor = Colors.black
                                  ..backgroundColor = Colors.transparent
                                  ..thickness = 4.0;
                              });
                              widget.onDoodleStart();
                            }
                          },
                          controller: _controller,
                          itemCount: post.type == PostType.shout
                              ? 1
                              : post.urlBundles.length,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Visibility(
                                visible: post.stats.likeCount +
                                        (_likedPost ? 0 : 1) +
                                        (postLiked ? 0 : -1) >
                                    0,
                                child: LikeCountBar(
                                  post: post,
                                  likeCount: post.stats.likeCount +
                                      (_likedPost ? 0 : 1) +
                                      (postLiked ? 0 : -1),
                                ),
                              ),

                              ///Caption
                              if (post.caption.isNotEmpty)
                                CommentPostListItem(
                                  uploader: post.owner,
                                  text: post.caption,
                                  onTap: () => Navigator.push(
                                      context, CommentScreen.route(post)),
                                ),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: <Widget>[
                                    ///View more comments button
                                    if (post.stats.commentCount > 0) ...[
                                      Material(
                                        color: Colors.white,
                                        child: InkWell(
                                          onTap: _onCommentTapped,
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
                                            widget.onAddComment(widget.post),
                                        child: Text(
                                          '${post.stats.commentCount > 0 ? 'A' : 'A'}dd comment',
                                          style:
                                              TextStyles.defaultText.copyWith(
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
                                    uploader: c.owner,
                                    text: c.text,
                                    onTap: () => Navigator.push(
                                        context, CommentScreen.route(post)),
                                  ),

                              ///Timestamp
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, bottom: 8.0),
                                child: Text(
                                  TimeAgo.formatLong(post.timestamp.toDate()),
                                  style: TextStyles.defaultText.copyWith(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )

//              StreamBuilder<DocumentSnapshot>(
//                  stream: Repo.myPostLikeStream(widget.post),
//                  builder: (context, snapshot) {
//                    if (!snapshot.hasData) return SizedBox();
//
//                    final liked = snapshot.data.exists;
//
//                    if (!postLikeIsInitiated) {
//                      likedPost = liked;
//                      postLikeIsInitiated = true;
//                    }
//
//                  }),
            ],
          );
  }

  Future<void> _onCommentTapped() async {
    final comments = await Navigator.of(context, rootNavigator: true)
        .push(CommentScreen.route(post));

    if (comments == null) return;
    if (comments is List<Comment> && comments.isNotEmpty)
      post = post.copyWith(topComments: post.topComments + comments);
  }
}
