import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:nutes/core/models/activity.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/tab_item.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/rtdb_provider.dart';
import 'package:nutes/core/services/storage_provider.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/utils/image_file_bundle.dart';

const scrollDuration = Duration(milliseconds: 300);
const scrollCurve = Curves.easeInOut;

class Repo {
//  static bool isHomeFirst = true;
//  static ScrollPhysics physics = ClampingScrollPhysics();

  final _firestore = FirestoreService();
  final _database = RTDBProvider();
  final _storage = FIRStorage();

  static final _instance = Repo();
  static UserProfile currentProfile;

//  static ScrollController homeScrollController = ScrollController();
//  static ScrollController searchScrollController = ScrollController();
//  static ScrollController profileScrollController = ScrollController();

//  static void animateToTop(TabItem tabItem) {
//    ScrollController controller;
//
//    print(tabItem);
//    switch (tabItem) {
//      case TabItem.home:
//        controller = homeScrollController;
//        break;
//      case TabItem.search:
//        controller = searchScrollController;
//        break;
//      case TabItem.create:
//        break;
//      case TabItem.activity:
//        break;
//      case TabItem.profile:
//        controller = profileScrollController;
//        break;
//    }
//
//    ///Scroll up if the controller is attached to a scroll view
//    if (controller.hasClients)
//      controller.animateTo(0, duration: scrollDuration, curve: scrollCurve);
//  }

  static Story myStory;
  // ignore: close_sinks

  static UserStory get currentUserStory => snapshot.userStories[storyIndex];
  static StorySnapshot snapshot = StorySnapshot(userStories: [], storyIndex: 0);

  static int get storyIndex => snapshot.storyIndex;
  static Story get currentStory => snapshot.userStories[storyIndex].story;

  static StreamController<StorySnapshot> storiesStreamController;
  static ScrollController storiesScrollController = ScrollController();

  static List<User> myUserFollowings;

  static Future<List<User>> getFollowersOfUser(String uid) =>
      _instance._firestore.getFollowersOfUser(uid);

  static Future<List<User>> getMyUserFollowings(String uid) =>
      _instance._firestore.getMyUserFollowings(uid);

  static Future<List<Activity>> getFollowingsActivity(List<User> followings) =>
      _instance._firestore.getFollowingsActivity(followings);

  static void refreshStream() {
    return storiesStreamController.add(snapshot);
  }

  static Stream<StorySnapshot> stream() {
    storiesStreamController =
        StreamController<StorySnapshot>.broadcast(onListen: () {
      print('on listen');
      storiesStreamController.add(snapshot);
    });
    return storiesStreamController.stream;
  }

  static void updateStoryIndex(int index) {
    final newSnap = snapshot.copyWith(storyIndex: index);
    snapshot = newSnap;
    return storiesStreamController.add(snapshot);
  }

  static void updateUserStories(List<UserStory> us) {
    snapshot = snapshot.copyWith(userStories: us);
    return Repo.refreshStream();
  }

  static void updateStory(int index, Story story) {
    var us = snapshot.userStories;

//    if (index == 0) {
//      if (us.where((u) => u.uploader.uid == Repo.currentUser.uid).isNotEmpty)
//        us[index].story = story;
//      else {
//        us.insert(0, UserStory(story, Repo.currentUser));
//      }
//    } else {
//      us[index].story = story;
//    }
    us[index].story = story;

    storiesStreamController.add(snapshot.copyWith(userStories: us));
    return Repo.refreshStream();
  }

  static void updateStoryFinished(int storyIndex, bool isFinished) {
    var st = snapshot.userStories;
    st[storyIndex].story =
        st[storyIndex].story.copyWith(isFinished: isFinished);
    return storiesStreamController.add(snapshot.copyWith(userStories: st));
  }

  static void updateStartAt(int storyIndex, int startAt) {
    var st = snapshot.userStories;
    st[storyIndex].story = st[storyIndex].story.copyWith(startAt: startAt);
    return storiesStreamController.add(snapshot.copyWith(userStories: st));
  }

  static final Stream<DocumentSnapshot> likesStream = _instance._firestore
      .activityRef(currentProfile.uid)
      .document('did_likes')
      .snapshots();

  static Stream<DocumentSnapshot> engagementStream() {
    return _instance._firestore
        .activityRef(currentProfile.uid)
        .document('did_likes')
        .snapshots();
  }

  static Future updateAccountPrivacy(bool isPrivate) async {
    return _instance._firestore.updateAccountPrivacy(isPrivate);
  }

  static Future deleteChatWithUser(User user) async {
    return _instance._firestore.deleteChatWithUser(user);
  }

  static Future<Timestamp> chatEndAtForUser(String uid) {
    return _instance._firestore.chatEndAtForUser(uid);
  }

  static Future<List<ChatItem>> getInitialMessages(
      {String chatId, Timestamp endAt}) {
    return _instance._firestore.getMessages(chatId, endAt);
  }

  static Future<List<ChatItem>> getMessages(
      {String chatId, Timestamp endAt, Timestamp startAt}) {
    return _instance._firestore.getMessages(chatId, endAt, startAt: startAt);
  }

  static Future isTyping(String chatId, String uid, bool isTyping) {
    return _instance._firestore.isTyping(chatId, uid, isTyping);
  }

  static Stream<QuerySnapshot> isTypingStream(String chatId) {
    return _instance._firestore.isTypingStream(chatId);
  }

  static Stream<QuerySnapshot> DMStream() {
    return _instance._firestore.DMStream();
  }

  static Stream<QuerySnapshot> messagesStream(String chatId) {
    return _instance._firestore.messagesStream(chatId);
  }

  static Stream<QuerySnapshot> messageStream(
      String chatId, Timestamp endAt, int limit) {
    return _instance._firestore.messageStream(chatId, endAt, limit);
  }

  static Stream<QuerySnapshot> messageStreamPaginated(
      String chatId, Timestamp endAt, DocumentSnapshot startAfter) {
    return _instance._firestore
        .messageStreamPaginated(chatId, endAt, startAfter);
  }

  static Stream<QuerySnapshot> chatStream() {
    return _instance._firestore.chatStream();
  }

  static Future likeShoutBubble(bool isChallenger, Post post) async {
    return _instance._firestore
        .likeShoutBubble(isChallenger: isChallenger, post: post);
  }

  static Future unlikeShoutBubble(bool isChallenger, Post post) async {
    return _instance._firestore
        .unlikeShoutBubble(isChallenger: isChallenger, post: post);
  }

  static Future likePost(Post post) async {
    return _instance._firestore.likePost(post);
  }

  static Future unlikePost(Post post) async {
//    likedPosts.remove(post.id);
//    updateLikeStream();
    return _instance._firestore.unlikePost(post);
  }

  static DocumentReference createMessageRef(String chatId) {
    return _instance._firestore.createMessageRef(chatId);
  }

  static completeShoutChallenge(
      {String chatId,
      String messageId,
      String content,
      String response,
      User peer}) {
    return _instance._firestore
        .completeShoutChallenge(chatId, messageId, content, response, peer);
  }

  static Future uploadMessage(
    DocumentReference ref,
    Bubbles type,
    String content,
    User peer,
  ) {
    return _instance._firestore.uploadMessage(ref, type, content, peer);
  }

  static Future<void> createMessage(
      {@required String chatId,
      @required User recipient,
      @required content,
      int type = 0}) {
    return _instance._firestore.createMessage(
        chatId: chatId, recipient: recipient, content: content, type: type);
  }

  static Future uploadStory({@required ImageFileBundle fileBundle}) async {
    final storyRef = _instance._firestore.createStoryRef();

    final url = await _instance._storage.uploadStoryFiles(
        storyId: storyRef.documentID,
        uid: currentProfile.uid,
        fileBundle: fileBundle);
    return await _instance._firestore.uploadStory(storyRef: storyRef, url: url);
  }

  ///Writes the shout to a public post collection
  ///
  ///Also writes to both participants' post collection so that the shout can
  ///be maintained (read/deleted) in their profile screen.
  ///
  ///The public ref is responsible for maintaining any post engagement
  ///activity such as likes, challenger likes
  ///
  static uploadPublicShout({
    @required User peer,
    @required Map data,
  }) async {
    final shoutRef = _instance._firestore.publicPostRef();
    final shoutId = shoutRef.documentID;

    final selfRef =
        _instance._firestore.userPostRef(Repo.currentProfile.uid, shoutId);

    final peerRef = _instance._firestore.userPostRef(peer.uid, shoutId);

    final timestamp = Timestamp.now();

    final payload = {
      'type': 'shout',
      'uploader': Repo.currentProfile.toMap(),
      'timestamp': timestamp,
      'data': data,
    };

    return _instance._firestore.runTransaction((t) {
      t.set(shoutRef, payload);
      t.set(selfRef, payload);
      return t.set(peerRef, payload);
    });
  }

  static uploadShout({@required User peer, @required Map data}) {
    return uploadPost(
        type: PostType.shout, isPrivate: false, peer: peer, metadata: data);
  }

  static uploadPost({
    @required PostType type,
    @required bool isPrivate,
    List<ImageFileBundle> fileBundles,
    User peer,
    Map metadata,
  }) async {
//    return print(type);
    final timestamp = Timestamp.now();

    final batch = _instance._firestore.batch();

    ///1. Set public post doc privacy field
    ///This public doc is used to maintain and query post stats(eg. like stats)

    final publicRef = _instance._firestore.publicPostRef();

    final postId = publicRef.documentID;

    print('new post: $postId');

    batch.setData(publicRef, {
      'owner_id': currentProfile.uid,
      'published': timestamp,
      'is_private': isPrivate,
    });

    ///2. set user post doc
    final myPostRef = _instance._firestore.myPostRef(postId);

    var bundleMaps;

    if (fileBundles != null) {
      ///Upload files to storage
      ///and then get the storage urls
      final uploadTasks = fileBundles
          .map((b) => _instance._storage.uploadPostFiles(
              postId: postId,
              index: b.index,
              uid: currentProfile.uid,
              fileBundle: b))
          .toList();
      final urlBundles = await Future.wait(uploadTasks);

      ///sort post urls in the right order
      urlBundles.sort((a, b) => a.index.compareTo(b.index));

      bundleMaps = urlBundles
              .map((b) => {
                    'original': b.original,
                    'medium': b.medium,
                    'small': b.small,
                  })
              .toList() ??
          {};
    }

    final uploader = currentProfile.user.toMap();

    final payload = {
      'type': PostHelper.stringValue(type),
      'uploader': uploader,
      'timestamp': timestamp,
      if (metadata != null) 'data': metadata,
      if (fileBundles != null) 'urls': bundleMaps,
    };

    batch.setData(myPostRef, payload);

    ///2b. Set peer user post ref if shout
    if (type == PostType.shout) {
      final peerPostRef = _instance._firestore.userPostRef(peer.uid, postId);
      batch.setData(peerPostRef, payload);
    }

    ///3. Cloud Functions - fanout write to followers' feeds
    ///
    /// 4?. fan out write to followers' activity

    return batch.commit();
  }

  ///current user's story stream
  static Stream<QuerySnapshot> myStoryStream() {
    return _instance._firestore.myStoryStream();
  }

  static Future<List<UserStory>> getSnapshotUserStories(
      {List<UserStory> userStories}) {
    return _instance._firestore.getSnapshotStories(userStories: userStories);
  }

  static Future<Story> getStoryForUser(String uid) {
    return _instance._firestore.getStoryForUser(uid);
  }

  ///fetch posts
  static Future<List<Post>> getFeed(
      {String uid, int limit, DocumentSnapshot startAfter}) async {
    final posts = await _instance._firestore.getFeed();

    ///To deal with error: Cannot remove from a fixed-length list
    var tempOutput = posts.toList();

    tempOutput.removeWhere((p) => p == null);

    return tempOutput;
  }

  ///fetch posts
  static Future<List<Post>> getMorePosts({int limit}) {
    return _instance._firestore.getMorePosts(limit: limit);
  }

  static Future<List> getMyFollowRequests() async {
    final doc = await _instance._firestore.myFollowRequestsRef().get();

    return doc.exists ? doc['requests'] ?? [] : [];
  }

  ///Deletes a follow request
  static redactFollowRequest(String followerId, String followingId) {
    _instance._firestore
        .deleteFollowRequest(follower: followerId, following: followingId);
  }

  static authorizeFollowRequest(String uid) {
    _instance._firestore
        .deleteFollowRequest(follower: uid, following: Repo.currentProfile.uid);
    return _instance._firestore
        .follow(followerId: uid, following: Repo.currentProfile.user);
  }

  static Map followingsArray = {};

  static Stream<DocumentSnapshot> myFollowingListStream() {
    return _instance._firestore.myFollowingListStream();
  }

  /// follow a user
  static requestFollow(User user, bool isPrivate) {
    isPrivate
        ? _instance._firestore.requestFollow(user.uid)
        : _instance._firestore
            .follow(followerId: Repo.currentProfile.uid, following: user);
  }

  /// unfollow a user
  static unfollowUser(String uid) {
    _instance._firestore.unfollow(uid);
  }

  /// check if following a user
//  static Future<bool> isFollowing({String follower, String following}) =>
//      _instance._firestore
//          .isFollowing(follower: follower, following: following);

  static Future<UserProfile> getUserProfile(String uid) =>
      _instance._firestore.getUserProfile(uid);

  static Future<bool> usernameExists(String name) =>
      _instance._firestore.usernameExists(name);

  static Future<User> getUser(String uid) => _instance._firestore.getUser(uid);

  ///returns a user object
  static Future<UserProfile> signInWithUsernameAndPassword(
      {String username, String password}) {
    print('repo signn in');
    return _instance._firestore
        .signInWithUsernameAndPassword(username: username, password: password);

//    return null;
  }

  static Future<UserProfile> createUser({
    @required String username,
    @required String password,
    @required String email,
  }) async {
    ///create FIRUser
    final authResult = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .catchError((err) {
      print(err);
      return null;
    });

    ///create user doc on firestore
    return (authResult != null)
        ? await _instance._firestore.signUp(
            uid: authResult.user.uid,
            username: username,
            email: authResult.user.email)
        : null;
  }

  static Future<UserStats> getUserStats(String uid) =>
      _instance._database.getUserStats(uid);

  static Stream<QuerySnapshot> myPostStream() =>
      _instance._firestore.myPostStream();

  static Future<List<Post>> getUserPosts(String uid) =>
      _instance._firestore.getUserPosts(uid);

  static Future<List<User>> getPostUserLikes(Post post) =>
      _instance._firestore.getPostUserLikes(post);

  static Future<PostCursor> getTrendingPosts(DocumentSnapshot startAfter) =>
      _instance._firestore.getTrendingPosts(startAfter);

  static Future<PostCursor> getNewestPosts(DocumentSnapshot startAfter) =>
      _instance._firestore.getNewestPosts(startAfter);

  static Future<List<Post>> getPostsForUser({
    String uid,
    int limit,
  }) async {
    List<Post> posts =
        await _instance._firestore.getPostsForUser(uid: uid, limit: limit);

    return posts;
  }

  ///Returns a complete post from an incomplete one
  static Future<Post> getPostStatsAndLikes(Post post) async {
    return _instance._firestore.getPostStatsAndLikes(post);
  }

  ///Returns a complete post from post id
  static Future<Post> getPostComplete(String postId, String ownerId) async {
    return _instance._firestore.getPostComplete(postId, ownerId);
  }

  static Future<UserProfile> updatePhotoUrl({String uid, File file}) async {
    final newUrl = await _instance._storage.uploadPhoto(uid: uid, file: file);
    _instance._firestore.updateProfile(photoUrl: newUrl);
    final updatedUser = currentProfile.copyWith(photoUrl: newUrl);
//    Repo.currentUser = newUser;
//    return newUser;
    return updatedUser;
  }

  static DocumentReference myRef() {
    return _instance._firestore.userRef(currentProfile.uid);
  }
}
