import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';

import 'package:flutter/widgets.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/moment_view.dart';
import 'package:nutes/utils/timeAgo.dart';

///
/// Callback function that accepts the index of moment and
/// returns its' Duration
///
typedef Duration MomentDurationGetter(int index);

///
/// Builder function that accepts current build context, moment index,
/// moment progress and gap between each segment and returns widget for segment
///
typedef Widget ProgressSegmentBuilder(
    BuildContext context, int index, double progress, double gap);

class StoryView extends StatefulWidget {
  StoryView({
    Key key,
    this.onFlashForward,
    this.onFlashBack,
//    this.startAt = 0,
    this.isFirstStory = false,
    this.story,
    this.onMomentChanged,
    this.uploader,
    this.onAvatarTapped,
    this.topPadding,
    this.seenStories,
    this.isOwner = false,
  })  :
//        assert(startAt != null),
//        assert(startAt >= 0),
//        assert(startAt == 0 || startAt < story?.moments.length),
        assert(onFlashForward != null),
        assert(onFlashBack != null),
        super(key: key);

  final bool isOwner;
  final Map seenStories;

  final User uploader;

  final Function(int) onMomentChanged;

  final Function(User) onAvatarTapped;

  final Story story;

  /// Gets executed when user taps the right portion of the screen
  /// on the last moment in story or when story finishes playing
  ///
  final VoidCallback onFlashForward;

  ///
  /// Gets executed when user taps the left portion
  /// of the screen on the first moment in story
  ///
  final VoidCallback onFlashBack;

  ///
  /// Sets the ratio of left and right tappable portions
  /// of the screen: left for switching back, right for switching forward
  ///
  final double momentSwitcherFraction = 0.26;

  ///
  /// Builder for each progress segment
  /// Defaults to Instagram-like minimalistic segment builder
  ///
  final ProgressSegmentBuilder progressSegmentBuilder =
      StoryView.instagramProgressSegmentBuilder;

  ///
  /// Sets the gap between each progress segment
  ///
  final double progressSegmentGap = 2.0;

  ///
  /// Sets the duration for the progress bar show/hide animation
  ///
  final Duration progressOpacityDuration = const Duration(milliseconds: 300);

  ///
  /// Sets the index of the first moment that will be displayed
  ///
//  final int startAt;

  final bool isFirstStory;

  ///Top padding for phones with notches etc
  final double topPadding;

  static Widget instagramProgressSegmentBuilder(
      BuildContext context, int index, double progress, double gap) {
    return Container(
      height: 2.0,
      margin: EdgeInsets.symmetric(horizontal: gap / 2),
      decoration: BoxDecoration(
        color: Color(0x80ffffff),
        borderRadius: BorderRadius.circular(1.0),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          color: Color(0xffffffff),
        ),
      ),
    );
  }

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  int momentIndex;
  bool isInFullscreenMode = false;
  Story story;

  PageController _momentPageController;

  @override
  void didUpdateWidget(StoryView oldWidget) {
    _play();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _init();

    super.initState();
  }

  Future<void> _init() async {
    if (widget.story == null) {
      print('story is null, get story');
      _getStory();
    } else {
      story = widget.story;

//      if (story.moments.isNotEmpty)
      _initAnimationController();
    }
  }

  void _initAnimationController() {
    final startAt = widget.seenStories[widget.uploader.uid] == null
        ? 0
        : story.moments.indexOf(story.moments.firstWhere(
            (m) =>
                m.timestamp.seconds >
                (widget.seenStories[widget.uploader.uid] as Timestamp).seconds,
            orElse: () => story.moments.first));
    momentIndex = startAt;

    _momentPageController = PageController(initialPage: momentIndex);

    controller = AnimationController(
      vsync: this,
      duration: story.moments[momentIndex].duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          switchToNextOrFinish();
        }
      });

    _play();
    widget.onMomentChanged(momentIndex);
  }

  Future _getStory() async {
    final st = await Repo.getStoryForUser(widget.uploader.uid);
    Repo.updateStory(Repo.storyIndex, st);
    setState(() {
      story = st;
      _initAnimationController();
    });
  }

  _stop() {
    controller.stop();
  }

  switchToNextOrFinish() {
    controller.stop();
    if (momentIndex + 1 >= story.moments.length) {
      widget.onFlashForward();
    } else {
      controller.reset();
      setState(() {
        momentIndex += 1;
        _momentPageController.jumpToPage(momentIndex);
      });
      controller.duration = story.moments[momentIndex].duration;
      _play();
      widget.onMomentChanged(momentIndex);
    }
  }

  switchToPrevOrFinish() {
    controller.stop();
    if (momentIndex - 1 < 0) {
      widget.isFirstStory ? onReset() : widget.onFlashBack();
    } else {
      controller.reset();
      setState(() {
        momentIndex -= 1;
        _momentPageController.jumpToPage(momentIndex);
      });
      controller.duration = story.moments[momentIndex].duration;
      _play();
      widget.onMomentChanged(momentIndex);
    }
  }

  onReset() {
    controller.reset();
    _play();
  }

  onTapDown(TapDownDetails details) {
    controller.stop();
  }

  onTapUp(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    if (details.localPosition.dx < width * widget.momentSwitcherFraction) {
      switchToPrevOrFinish();
    } else {
      switchToNextOrFinish();
    }
  }

  onLongPress() {
    print('onlongpress');
    controller.stop();
    setState(() => isInFullscreenMode = true);
  }

  onLongPressEnd() {
    print('onlongpress end');

    setState(() => isInFullscreenMode = false);
    _play();
  }

  ///Resumes the animation controller
  ///provided the current moment has been loaded
  void _play() {
    if (story == null || widget.story == null) return;
    if (story.moments.isEmpty) return;

    ///if momentIndex is not in ranged (due to deletion)
    if (momentIndex > story.moments.length - 1) return;

    if (story.moments[momentIndex].isLoaded) controller.forward();
  }

  @override
  void dispose() {
//    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    print('dispose moment');

    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: story == null
          ? Container(color: Colors.grey[600])
          : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ///Moment Image
                Positioned.fill(
                  child: PageView.builder(
                    controller: _momentPageController,
                    itemBuilder: (context, index) {
                      if (story.moments.isEmpty ||
                          index > story.moments.length - 1) return SizedBox();

                      final moment = story.moments[index];

                      return MomentView(
                        isFooterVisible: !isInFullscreenMode,
                        moment: moment,
                        uploader: widget.uploader,
                        onLoad: () {
                          moment.isLoaded = true;
                          _play();
                        },
                        onError: () {},
                        onSeenByTapped: () {
                          _stop();
                        },
                        onDeleteTapped: () {
                          _stop();
                          _showConfirmDelete();
                        },
                      );
                    },
                  ),
                ),

                ///header
                Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedOpacity(
                    opacity: isInFullscreenMode ? 0.0 : 1.0,
                    duration: widget.progressOpacityDuration,
                    child: Container(
                      height: 184 + widget.topPadding ?? 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.16),
                            Colors.black.withOpacity(0.04),
                            Colors.transparent,
                          ],
                          stops: [0.06, 0.44, 0.86],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),

                ///progress bar
                Positioned(
                  top: (widget.topPadding ?? 24.0),
                  left: 8.0 - widget.progressSegmentGap / 2,
                  right: 8.0 - widget.progressSegmentGap / 2,
                  child: AnimatedOpacity(
                    opacity: isInFullscreenMode ? 0.0 : 1.0,
                    duration: widget.progressOpacityDuration,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            ...List.generate(
                              story.moments.length,
                              (idx) {
                                return Expanded(
                                  child: idx == momentIndex
                                      ? AnimatedBuilder(
                                          animation: controller,
                                          builder: (context, _) {
                                            return widget
                                                .progressSegmentBuilder(
                                              context,
                                              idx,
                                              controller.value,
                                              widget.progressSegmentGap,
                                            );
                                          },
                                        )
                                      : widget.progressSegmentBuilder(
                                          context,
                                          idx,
                                          idx < momentIndex ? 1.0 : 0.0,
                                          widget.progressSegmentGap,
                                        ),
                                );
                              },
                            ),
                          ],
                        ),

                        ///Avatar
                        Container(
                          height: 44,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _stop();
                                    Navigator.of(context).push(
                                        ProfileScreen.route(
                                            widget.uploader.uid));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      AvatarImage(
                                        bordered: false,
                                        url: widget.uploader.urls.small,
                                        spacing: 0,
                                        padding: 8,
                                        addStory: false,
                                      ),
                                      Expanded(
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text: widget.uploader.username,
                                              style:
                                                  TextStyles.w500Text.copyWith(
                                                color: Colors.white,
                                                fontSize: 15,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 4.0,
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextSpan(text: '  '),
                                            if (widget
                                                    .story.moments.isNotEmpty &&
                                                momentIndex <=
                                                    widget.story.moments
                                                            .length -
                                                        1)
                                              TextSpan(
                                                text: TimeAgo.formatShort(widget
                                                    .story
                                                    .moments[momentIndex]
                                                    .timestamp
                                                    .toDate()),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w300,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 4.0,
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CancelButton(
                                onPressed: () {
                                  if (mounted) Navigator.of(context).pop();
                                  return;
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  bottom: widget.isOwner ? 64 : 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: onTapDown,
                    onTapUp: onTapUp,
                    onLongPress: onLongPress,
                    onLongPressUp: onLongPressEnd,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showConfirmDelete() {
    return showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              content: Text('Delete this story?'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    _play();
                    return Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                  isDefaultAction: true,
                ),
                CupertinoDialogAction(
                  onPressed: () async {
                    final moment = widget.story.moments[momentIndex];

//                    setState(() {
//                      momentIndex = 0;
//                      story.moments.remove(moment);
//                    });
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    Repo.deleteStory(moment);
//

//                    controller.forward();
//                    Navigator.of(context).pop();
//                    _play();
                    return;
                  },
                  child: Text('Delete'),
                  isDestructiveAction: true,
                ),
              ],
            ));
  }
}
