import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/story_avatar.dart';
import 'package:nutes/ui/widgets/profile_header.dart';
import 'package:nutes/ui/widgets/story_page_view.dart';
import 'package:provider/provider.dart';

class InlineStories extends StatefulWidget {
  final List<UserStory> userStories;
  final VoidCallback onCreateStory;
  final double topPadding;

  const InlineStories(
      {Key key, this.userStories, this.onCreateStory, this.topPadding})
      : super(key: key);

  @override
  _InlineStoriesState createState() => _InlineStoriesState();
}

class _InlineStoriesState extends State<InlineStories> {
  int buttonTapped;

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfile>(context);

    return StreamBuilder<DocumentSnapshot>(
        stream: Repo.seenStoriesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoadingIndicator();

          final data = snapshot.data.data ?? {};

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            controller: Repo.storiesScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.userStories?.length ?? 0,
            itemBuilder: (context, index) {
              final userStory = widget.userStories[index];
              final isOwner = profile.uid == userStory.uploader.uid;

              final Timestamp seenStoryTimestamp = data[userStory.uploader.uid];

              final storyState = userStory.lastTimestamp == null
                  ? StoryState.none
                  : seenStoryTimestamp == null
                      ? StoryState.unseen
                      : seenStoryTimestamp.seconds <
                              userStory.lastTimestamp.seconds
                          ? StoryState.unseen
                          : StoryState.seen;

              return StoryAvatar(
                isOwner: isOwner,
                storyState: storyState,
                isEmpty: false,
                user: userStory.uploader,
                onLongPress: isOwner ? widget.onCreateStory : null,
                onTap: isOwner && userStory.story.moments.isEmpty
                    ? () => LocalCache.instance.animateTo(0)
                    : () {
                        setState(() {
                          buttonTapped = index;
                        });

//                        Repo.updateStoryIndex(index);

                        StoryPageView.show(
                          context,
                          initialPage: index,
                          topPadding: widget.topPadding,
                          userStories: widget.userStories,
                          onPageChange: (val) {},
                        );

                        setState(() {
                          buttonTapped = null;
                        });
                      },
              );
            },
          );
        });
  }
}
