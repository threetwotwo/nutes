import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/my_profile_screen.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/widgets/story_view.dart';

class StoryPageView extends StatefulWidget {
  final int initialPage;
  final List<UserStory> userStories;
  final double topPadding;
  final Function(int) onPageChange;

  static show(context,
          {int initialPage,
          List<UserStory> userStories,
          double topPadding,
          Function(int) onPageChange}) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height,
          child: StoryPageView(
            initialPage: initialPage,
            userStories: userStories,
            topPadding: topPadding + 8,
            onPageChange: (val) => onPageChange(val),
          ),
        ),
      );

  const StoryPageView({
    Key key,
    this.userStories,
    this.initialPage,
    this.topPadding,
    this.onPageChange,
  }) : super(key: key);

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  PageController controller;
  final auth = Repo.auth;
  List<UserStory> userStories;
  Map<String, Timestamp> momentsSeen = {};

  Map<String, dynamic> seenStories;

  @override
  void dispose() {
    print('disposed, should update moments seen in firestore');
    print(momentsSeen);

    Repo.updateSeenStories(momentsSeen);

    super.dispose();
  }

  @override
  void initState() {
    controller = PageController(initialPage: widget.initialPage);

    userStories = widget.userStories;

    _getSeenStories();

    super.initState();
  }

  _getSeenStories() async {
    final result = await Repo.getSeenStories();
    setState(() {
      seenStories = result;
    });
  }

  nextPage() {
    return controller.nextPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  previousPage() {
    return controller.previousPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  _getStoryForIndex(int index) async {
    final currentUserStory = userStories[index];
    final result = await Repo.getStoryForUser(currentUserStory.uploader.uid);

    setState(() {
      userStories[index] = currentUserStory.copyWith(story: result);
    });
  }

  _pop() {
    //TODO: prevent popping twice at the last moment
    if (mounted) return Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return seenStories == null
        ? Container(
            color: Colors.black87,
            child: Center(child: LoadingIndicator()),
          )
        : PageView.builder(
            itemCount: userStories.length,
            onPageChanged: (val) {
              widget.onPageChange(val);

              ///Auto scroll functionality
              ///
              final screenWidth = MediaQuery.of(context).size.width;

              ///max number of items that can be shown
              final maxItemCount = (screenWidth ~/ 80.0);

              ///Story avatar offset
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
            },
            controller: controller,
            itemBuilder: (context, storyIndex) {
              final userStory = userStories[storyIndex];
              if (userStory.story == null) {
                _getStoryForIndex(storyIndex);
                return Container(
                  color: Colors.black87,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 1,
                    ),
                  ),
                );
              }

              return StoryView(
                seenStories: seenStories,
                topPadding: widget.topPadding,
                onAvatarTapped: (user) =>
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => user.uid == auth.uid
                            ? MyProfileScreen(isRoot: false)
                            : ProfileScreen(
                                uid: user.uid,
                              ))),
                uploader: userStory.uploader,
                story: userStory.story,
                isFirstStory: storyIndex == 0,
                onFlashForward: storyIndex == widget.userStories.length - 1
                    ? () => _pop()
                    : nextPage,
                onFlashBack: previousPage,
                onMomentChanged: (val) {
                  final timestamp =
                      userStories[storyIndex].story.moments[val].timestamp;

                  final FIRtimestamp =
                      (seenStories[userStory.uploader.uid] as Timestamp);

                  if (FIRtimestamp == null ||
                      FIRtimestamp.seconds < timestamp.seconds)
                    momentsSeen[userStories[storyIndex].uploader.uid] =
                        timestamp;
                },
              );
            },
          );
  }
}
