import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/buttons.dart';
//import 'package:cached_network_image/cached_network_image.dart';

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
    this.startAt = 0,
    this.isFirstStory = false,
    this.story,
    this.onMomentChanged,
    this.uploader,
    this.onAvatarTapped,
  })  : assert(startAt != null),
        assert(startAt >= 0),
//        assert(startAt == 0 || startAt < story?.moments.length),
        assert(onFlashForward != null),
        assert(onFlashBack != null),
        super(key: key);

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
  final int startAt;

  final bool isFirstStory;

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

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);

    print('initState StoryView ${widget.uploader.username}');

    if (widget.story == null) {
      print('story is null, get story');
      _getStory();
    } else {
      story = widget.story;

      _initAnimationController();
    }

    super.initState();
  }

  void _initAnimationController() {
    momentIndex = widget.startAt;

    controller = AnimationController(
      vsync: this,
      duration: story.moments[momentIndex].duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          switchToNextOrFinish();
        }
      });

//    _play();
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
    if (story.moments[momentIndex].isLoaded) controller.forward();
  }

  @override
  void dispose() {
//    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//    controller.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: story == null
          ? Container(color: Colors.pink)
          : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned.fill(
                  child: Image.network(
                    story.moments[momentIndex].url ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      print(progress);
                      if (progress.cumulativeBytesLoaded ==
                              progress.expectedTotalBytes &&
                          mounted) {
                        print('image load complete');
                        story.moments[momentIndex].isLoaded = true;
                        _play();
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
//                          value: progress.expectedTotalBytes != null
//                              ? progress.cumulativeBytesLoaded /
//                                  progress.expectedTotalBytes
//                              : null,
                        ),
                      );
                    },
                  ),
//                  child: CachedNetworkImage(
//                    fit: BoxFit.cover,
//                    imageUrl: story.moments[momentIndex].url,
//                    placeholder: (context, _) => Container(
//                      width: 50,
//                      child: SpinKitCircle(color: Colors.white),
//                    ),
//                    imageBuilder: (context, provider) {
//                      provider
//                          .resolve(ImageConfiguration())
//                          .addListener(ImageStreamListener((info, b) {
//                        if (mounted) {
//                          story.moments[momentIndex].isLoaded = true;
//                          _play();
//                        }
//                      }));
//                      return Image.network(story.moments[momentIndex].url);
//                    },
//                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedOpacity(
                    opacity: isInFullscreenMode ? 0.0 : 1.0,
                    duration: widget.progressOpacityDuration,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black26, Colors.transparent],
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topOffset + 8,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AvatarListItem(
                            avatar: AvatarImage(
                              bordered: false,
                              url: widget.uploader.photoUrl,
                              spacing: 0,
                              padding: 12,
                              addStory: false,
                            ),
                            title: widget.uploader.username,
                            onAvatarTapped: () {
                              print('story view avatar '
                                  'tapped');
                              _stop();
                              return widget.onAvatarTapped(widget.uploader);
                            },
                            onBodyTapped: () {
                              _stop();
                              return widget.onAvatarTapped(widget.uploader);
                            },
                            trailingWidget: CancelButton(
                              onPressed: () {
                                SystemChrome.setEnabledSystemUIOverlays(
                                    SystemUiOverlay.values);

                                if (mounted) Navigator.of(context).pop();
                                return;
                              },
                            ),
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
                  bottom: 0,
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
}

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  /// The page content
  final Widget view;

  StoryItem(
    this.view, {
    this.duration = const Duration(seconds: 3),
//    this.shown = false,
  }) : assert(duration != null, "[duration] should not be null");
}
