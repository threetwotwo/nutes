import 'package:flutter/material.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/story_avatar.dart';
import 'package:nutes/ui/widgets/story_page_view.dart';

class InlineStories extends StatefulWidget {
  final List<UserStory> userStories;
  final VoidCallback onCreateStory;

  const InlineStories({Key key, this.userStories, this.onCreateStory})
      : super(key: key);

  @override
  _InlineStoriesState createState() => _InlineStoriesState();
}

class _InlineStoriesState extends State<InlineStories> {
  int buttonTapped;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      controller: Repo.storiesScrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.userStories?.length ?? 0,
      itemBuilder: (context, index) {
        final userStory = widget.userStories[index];

        return Stack(
          children: <Widget>[
            StoryAvatar(
              heroTag: userStory.uploader.uid,
              isFinished: userStory.story?.isFinished ?? false,
              isEmpty: false,
              user: userStory.uploader,
              onLongPress: userStory.uploader.uid == Repo.currentProfile.uid
                  ? widget.onCreateStory
                  : null,
              onTap: () async {
                setState(() {
                  buttonTapped = index;
//
                });

                Story currentStory = Repo.snapshot.userStories[index].story;

                ///Get story for user
                if (currentStory == null) {
                  currentStory =
                      await Repo.getStoryForUser(userStory.uploader.uid);

                  Repo.updateStory(index, currentStory);
                }

                if (currentStory.isFinished) {
                  Repo.updateStartAt(index, 0);
                }

                Repo.updateStoryIndex(index);

                final topOffset = MediaQuery.of(context).padding.top;

                print(topOffset);

                StoryPageView.show(context, index, widget.userStories);

//                Navigator.of(context, rootNavigator: true)
//                    .push(StoryPageView.route(index, widget.userStories));

                setState(() {
                  buttonTapped = null;
                });
              },
            ),
          ],
        );
//                  return AspectRatio(
//                    aspectRatio: 1,
//                    child: Container(
//                      child: Column(
//                        mainAxisSize: MainAxisSize.max,
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Stack(
//                            alignment: Alignment.center,
//                            children: <Widget>[
//                              FloatingActionButton(
//                                backgroundColor: (buttonTapped == index)
//                                    ? Colors.red
//                                    : Colors.blue,
//                                heroTag: index,
//                                elevation: 0,
//                                onPressed: () async {
//                                  ///1. On story pressed, update
//                                  ///indexes/booleans
//                                  setState(() {
//                                    buttonTapped = index;
////
//                                  });
//
//                                  Story currentStory =
//                                      snap.userStories[index].story;
//                                  if (currentStory == null) {
//                                    currentStory = await Repo.getStoryForUser(
//                                        userStory.uploader.uid);
//
//                                    Repo.updateStory(index, currentStory);
//                                  }
//
//                                  Repo.updateStoryIndex(index);
//
//                                  Navigator.of(context, rootNavigator: true)
//                                      .push(
//                                    MaterialPageRoute(
//                                      fullscreenDialog: true,
//                                      builder: (context) => StoryPageView(
//                                          userStories: userStories),
//                                    ),
//                                  );
//
//                                  setState(() {
//                                    buttonTapped = null;
////
////
//                                  });
//
//                                  /// 2. Check to see if: (a) moments are
//                                  /// loaded and (b) if there are new moments
//                                  /// Fetch moments if needed
//                                  /// 3. Present story viewer once moments
//                                  /// are loaded
//                                },
//                                child: AvatarImage(
//                                  url: userStories[index].uploader.photoUrl,
//                                  spacing: 2,
//                                  showStoryIndicator: false,
//                                ),
//                              ),
//                              if (buttonTapped == index)
//                                FloatingActionButton(
//                                  elevation: 0,
//                                  onPressed: () {},
//                                  backgroundColor:
//                                      Colors.black.withOpacity(0.4),
//                                ),
//                              if (buttonTapped == index)
//                                Align(
//                                  alignment: Alignment.center,
//                                  child: CircularProgressIndicator(
//                                      strokeWidth: 1.4,
//                                      valueColor: AlwaysStoppedAnimation<Color>(
//                                          Colors.white)),
//                                ),
//                            ],
//                          ),
//                          Text(userStories[index].uploader.username),
//                        ],
//                      ),
//                    ),
//                  );
      },
    );
  }
}
