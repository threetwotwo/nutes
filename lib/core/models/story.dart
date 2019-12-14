import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';

///Object to represent users who have uploaded stories recently
///To be used in Inline Stories for laxy loading of stories(load stories only
/// when avatar is tapped)
class UserStory {
  Story story;
  final User uploader;

  ///Timestamp of most recent moment
  final Timestamp lastTimestamp;

  UserStory({this.story, this.uploader, this.lastTimestamp});

  static UserStory fromDoc(
    DocumentSnapshot doc,
  ) {
    final uploader = User.fromMap(doc['uploader'] ?? {});

    print(uploader.toMap());
    return UserStory(
      story: null,
      uploader: uploader,
      lastTimestamp: doc['timestamp'],
    );
//    final data = doc.data ?? {};
//    final Map followingMap = data['followings'] ?? {};
//
//    final now = Timestamp.now();
//
//    final todayInSeconds = now.seconds;
//    final todayInNanoSeconds = now.nanoseconds;
//
//    ///24 hours ago since now
//    final cutOff = Timestamp(todayInSeconds - 86400, todayInNanoSeconds);
//
//    ///remove old data
//    followingMap.removeWhere((key, value) =>
//        (value['timestamp'] == null) ||
//        (value['timestamp'] as Timestamp).microsecondsSinceEpoch <
//            cutOff.microsecondsSinceEpoch);
//
////    final uids = followingMap.keys.toList().cast<String>();
//
//    ///sort by timestamp
//    final sortedKeys = followingMap.keys.toList()
//      ..sort((a, b) {
//        print(
//            (followingMap[a]['timestamp'] as Timestamp).millisecondsSinceEpoch);
//        print(
//            (followingMap[b]['timestamp'] as Timestamp).millisecondsSinceEpoch);
//        return (followingMap[b]['timestamp'] as Timestamp)
//            .millisecondsSinceEpoch
//            .compareTo((followingMap[a]['timestamp'] as Timestamp)
//                .millisecondsSinceEpoch);
//      });
//
//    print(sortedKeys);
//
//    final users = await FirestoreService()
//        .getAbridgedUserFromUids(sortedKeys.cast<String>());
//
//    print('user stories: ${users.map((user) => user.username).toList()}');
//
//    return users.map((user) {
//      if (userStories != null) {
//        final match = userStories.firstWhere(
//            (us) => us.uploader.uid == user.uid,
//            orElse: () => null);
//        Story story;
//
//        return UserStory(null, user);
//      } else
//        return UserStory(null, user);
//    }).toList();
  }

  UserStory copyWith({Story story, Timestamp lastTimestamp}) {
    return UserStory(
      story: story ?? this.story,
      uploader: this.uploader,
      lastTimestamp: lastTimestamp ?? this.lastTimestamp,
    );
  }
}

///Snapshot of user stories
///
/// to be used within a streambuilder
class StorySnapshot {
  final List<UserStory> userStories;
  final int storyIndex;

  StorySnapshot({this.userStories, this.storyIndex});

  StorySnapshot copyWith({
    List<UserStory> userStories,
    int storyIndex,
    int momentIndex,
  }) {
    return StorySnapshot(
      userStories: userStories ?? this.userStories,
      storyIndex: storyIndex ?? this.storyIndex,
//      momentIndex: momentIndex ?? this.momentIndex,
    );
  }
}

class Story {
  ///Flag to track if all moments have been viewed
  bool isFinished;

  ///For continuation when swiping through stories
//  final int startAt;

  ///For start point when story is pressed(Experimental)
//  final int lastLoaded;
  final List<Moment> moments;

  Story({
//    this.startAt,
//    this.lastLoaded,
    this.moments,
    this.isFinished = false,
  });

//  factory Story.fromDoc(DocumentSnapshot doc) {
//    return Story()
//  }

  Story copyWith({
    int startAt,
    int lastLoaded,
    bool isFinished,
    bool persistSeen,
  }) {
    return Story(
//      startAt: startAt ?? this.startAt,
//      lastLoaded: lastLoaded ?? this.lastLoaded,
      isFinished: isFinished ?? this.isFinished,
      moments: this.moments,
    );
  }

  factory Story.empty() {
    return Story(
//      startAt: 0,
//      lastLoaded: 0,
      moments: [],
    );
  }
}

class Moment {
  final String id;
  final String url;
  final Timestamp timestamp;
  bool isLoaded;
  final Duration duration = Duration(seconds: 3);

  Moment({
    this.id,
    this.url,
    this.timestamp,
    this.isLoaded = false,
//    this.duration ,
  });

  factory Moment.fromDoc(DocumentSnapshot ds) {
    return Moment(
      id: ds.documentID,
      url: ds['url'] ?? '',
      timestamp: ds['timestamp'] ?? Timestamp.now(),
    );
  }
}
