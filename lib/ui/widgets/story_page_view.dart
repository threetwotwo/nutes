import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/my_profile_screen.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/widgets/story_view.dart';

class StoryPageView extends StatefulWidget {
//  final PageController controller;
  final int initialPage;
  final List<UserStory> userStories;
  final Function(int) onPageChanged;
  final Widget bgWidget;
//  final String heroTag;

  static show(context, int initialPage, List<UserStory> userStories) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height,
          child: StoryPageView(
            initialPage: initialPage,
            userStories: userStories,
            onPageChanged: (val) {},
          ),
        ),
      );

  static Route route(int initialPage, List<UserStory> userStories,
          {Widget bgWidget}) =>
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => StoryPageView(
          initialPage: initialPage,
          userStories: userStories,
          onPageChanged: (val) {},
          bgWidget: bgWidget ?? SizedBox(),
        ),
      );

  const StoryPageView({
    Key key,
    this.userStories,
    this.initialPage,
    this.onPageChanged,
    this.bgWidget,
//    this.heroTag,
  }) : super(key: key);

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  PageController controller;

//  final topOffset = MediaQuery.of(context).padding.top;

  @override
  void initState() {
    controller = PageController(initialPage: widget.initialPage);

    super.initState();
  }

  nextPage() {
    return controller.nextPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  previousPage() {
    return controller.previousPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  _pop() {
    ///Restore ui overlays

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    //TODO: prevent popping twice at the last moment
    if (mounted) return Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorySnapshot>(
        stream: Repo.stream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();

          final snap = snapshot.data;
          return PageView.builder(
            itemCount: snap.userStories.length,
            onPageChanged: (val) {
              Repo.updateStoryIndex(val);

              ///Auto scroll functionality
              ///
              final screenWidth = MediaQuery.of(context).size.width;

              ///max number of items that can be shown
              final maxItemCount = (screenWidth ~/ 80.0);

              final offset = Repo.storiesScrollController.offset;

              ///Estimation of the index of the last item
              ///given the current offset of the scroll controller
              final estimatedLastItemIndex =
                  (offset / 80.0 + maxItemCount).floor();

              setState(() {
                if (val >= estimatedLastItemIndex)
                  Repo.storiesScrollController
                      .jumpTo(80.0 * estimatedLastItemIndex);
              });

              return widget.onPageChanged(val);
            },
            controller: controller,
            itemBuilder: (context, storyIdx) {
              final userStory = snap.userStories[storyIdx];
              print('user story: $userStory, story: ${userStory.story}');
              return StoryView(
                onAvatarTapped: (user) => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            user.uid == Repo.currentProfile.uid
                                ? MyProfileScreen(isRoot: false)
                                : ProfileScreen(
                                    uid: user.uid,
                                  ))),
                uploader: userStory.uploader,
                story: userStory.story,
                startAt: userStory.story?.startAt ?? 0,
                isFirstStory: storyIdx == 0,
                onFlashForward: storyIdx == snap.userStories.length - 1
                    ? () => _pop()
                    : nextPage,
                onFlashBack: previousPage,
                onMomentChanged: (val) {
                  print('story $storyIdx moment $val}');
                  Repo.updateStartAt(storyIdx, val);
                  final isFinished = val >= userStory.story.moments.length - 1;
                  if (isFinished)
                    Repo.updateStoryFinished(storyIdx, isFinished);
                },
              );
            },
          );
        });
  }
}
