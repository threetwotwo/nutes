import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:image/image.dart' as img;
import 'package:meta/meta.dart';
import 'package:nutes/core/models/activity.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/services/auth.dart';
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

  static final auth = Auth.instance;

  static final _instance = Repo();
//  static UserProfile currentProfile;

  static Story myStory;

  static UserStory get currentUserStory => snapshot.userStories[storyIndex];
  static StorySnapshot snapshot = StorySnapshot(userStories: [], storyIndex: 0);

  static int get storyIndex => snapshot.storyIndex;
  static Story get currentStory => snapshot.userStories[storyIndex].story;

  static StreamController<StorySnapshot> storiesStreamController;
  static ScrollController storiesScrollController = ScrollController();

  static List<User> myUserFollowings;

  static Future<List<User>> getFollowersOfUser(String uid) =>
      _instance._firestore.getFollowersOfUser(uid);

  static Future<List<User>> getFollowingsOfUser(String uid) =>
      _instance._firestore.getFollowingsOfUser(uid);

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

  static Future likeShout(bool isChallenger, Post post) async {
    return _instance._firestore
        .likeShout(isChallenger: isChallenger, post: post);
  }

  static Future unlikeShout(bool isChallenger, Post post) async {
    return _instance._firestore
        .unlikeShout(isChallenger: isChallenger, post: post);
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
        uid: Auth.instance.profile.uid,
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
        _instance._firestore.userPostRef(Auth.instance.profile.uid, shoutId);

    final peerRef = _instance._firestore.userPostRef(peer.uid, shoutId);

    final timestamp = Timestamp.now();

    final payload = {
      'type': 'shout',
      'uploader': auth.profile.toMap(),
      'timestamp': timestamp,
      'data': data,
    };

    return _instance._firestore.runTransaction((t) {
      t.set(shoutRef, payload);
      t.set(selfRef, payload);
      return t.set(peerRef, payload);
    });
  }

  static uploadComment({
    @required String postId,
    @required Comment comment,
//    @required User owner,
//    @required String text,
//    String parentId,
  }) async {
    return _instance._firestore.uploadComment(postId: postId, comment: comment);
  }

  static Future updatePost({@required Post post}) async {
    final updatedPost = post.toMap();
    print(updatedPost);

    final postRef = _instance._firestore.userPostRef(post.owner.uid, post.id);

    postRef.setData(updatedPost, merge: true);
  }

  static Future uploadShout({@required User peer, @required Map data}) {
    return uploadPost(
        type: PostType.shout, isPrivate: false, peer: peer, metadata: data);
  }

  static Future uploadPost({
    @required PostType type,
    @required bool isPrivate,
    List<ImageFileBundle> fileBundles,
    User peer,
    Map metadata,
    String caption,
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
      'owner_id': Auth.instance.profile.uid,
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
          .map((b) => _instance._storage
              .uploadPostFiles(postId: postId, index: b.index, fileBundle: b))
          .toList();
      final urlBundles = await Future.wait(uploadTasks);

      ///sort post urls in the right order
      urlBundles.sort((a, b) => a.index.compareTo(b.index));

      bundleMaps = urlBundles
              .map((b) => {
                    'original': b.original,
                    'medium': b.medium,
                    'small': b.small,
                    'aspect_ratio': b.aspectRatio ?? 1,
                  })
              .toList() ??
          {};
    }

    final uploader = Auth.instance.profile.user.toMap();

    print('post uploader: $uploader');

    final payload = {
      'type': PostHelper.stringValue(type),
      'uploader': uploader,
      'timestamp': timestamp,
      'caption': caption ?? '',
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
    return _instance._firestore.myStoryStream(auth.profile.uid);
  }

  static Future<Map<String, dynamic>> getSeenStories() =>
      _instance._firestore.getSeenStories();

  static Stream<DocumentSnapshot> seenStoriesStream() =>
      _instance._firestore.seenStoriesStream();

  static Future updateSeenStories(Map<String, Timestamp> data) =>
      _instance._firestore.updateSeenStories(data);

  static Future<List<UserStory>> getStoriesOfFollowings(
      {List<UserStory> userStories}) {
    return _instance._firestore.getStoriesOfFollowings();
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
        .deleteFollowRequest(follower: uid, following: auth.profile.uid);
    return _instance._firestore
        .follow(followerId: uid, following: auth.profile.user);
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
            .follow(followerId: auth.profile.uid, following: user);
  }

  /// unfollow a user
  static void unfollowUser(String uid) {
    _instance._firestore.unfollow(uid);
  }

  /// check if following a user
//  static Future<bool> isFollowing({String follower, String following}) =>
//      _instance._firestore
//          .isFollowing(follower: follower, following: following);

  static Future<UserProfile> getUserProfileFromUsername(String username) =>
      _instance._firestore.getUserProfileFromUsername(username);

  static Future<UserProfile> getUserProfile(String uid) =>
      _instance._firestore.getUserProfile(uid);

  static Future getRecentSearches() => _instance._firestore.getRecentSearches();

  static Future deleteRecentSearch(String uid) =>
      _instance._firestore.deleteRecentSearch(uid);

  static Future createRecentSearch(User user) =>
      _instance._firestore.createRecentSearch(user);

  static Future<List<User>> searchUsers(String text) =>
      _instance._firestore.searchUsers(text);

  static Future<bool> usernameExists(String name) =>
      _instance._firestore.usernameExists(name);

  static Future<User> getUser(String uid) => _instance._firestore.getUser(uid);

  static Future<void> logout() => _instance._firestore.logout();

  ///returns a user object
  static Future<UserProfile> signInWithUsernameAndPassword(
      {String username, String password}) async {
    print('repo sign in $username');
    final user = await _instance._firestore
        .signInWithUsernameAndPassword(username: username, password: password);

    auth.reset();

    auth.profile = user;

    return user;
  }

  static Future<UserProfile> createUser({
    @required String username,
    @required String password,
    @required String email,
  }) async {
    print('create user $username');

    ///create FIRUser
    final authResult = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .catchError((err) {
      print(err);
      return null;
    });

    ///create user doc on firestore
    return (authResult != null)
        ? await _instance._firestore.createUser(
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

  static Comment createComment(
          {@required String text,
          @required String postId,
          Comment parentComment}) =>
      _instance._firestore
          .newComment(text: text, postId: postId, parentComment: parentComment);

  static Future<List<Comment>> getComments(String postId) async =>
      _instance._firestore.getComments(postId);

  ///Returns a complete post from an incomplete one
  static Future<Post> getPostStatsAndLikes(Post post) async {
    return _instance._firestore.getPostStatsAndLikes(post);
  }

  ///Returns a complete post from post id
  static Future<Post> getPostComplete(String postId, String ownerId) async {
    return _instance._firestore.getPostComplete(postId, ownerId);
  }

  static Future<UserProfile> removeCurrentPhoto() async {
    _instance._storage.removeCurrentPhoto();
    return _instance._firestore.updateProfile(urls: ImageUrlBundle.empty());
//    final updatedUser = Auth.instance.profile.copyWith(photoUrl: '');
  }

  static Future<UserProfile> updatePhotoUrl({String uid, File original}) async {
    final image = img.decodeImage(original.readAsBytesSync());
    final medium = img.copyResize(image, width: 300);
    final small = img.copyResize(image, width: 80);
    final directory =
        (await path_provider.getApplicationDocumentsDirectory()).path;
    String fileName = DateTime.now().toIso8601String();

    final mediumPath = '$directory/${fileName}medium.png';
    final smallPath = '$directory/${fileName}small.png';

    final bundle = await _instance._storage.uploadPhoto(
        uid: uid,
        fileBundle: ImageFileBundle(
            original: original,
            medium: File(mediumPath)..writeAsBytesSync(img.encodeJpg(medium)),
            small: File(smallPath)..writeAsBytesSync(img.encodeJpg(small))));

    print('bundle uploaded: $bundle');

    return _instance._firestore.updateProfile(urls: bundle);
  }

  static DocumentReference myRef() {
    return _instance._firestore.userRef(auth.profile.uid);
  }

  static Stream<DocumentSnapshot> myPostLikeStream(Post post) =>
      _instance._firestore.myPostLikeStream(post);

  static Stream<DocumentSnapshot> myShoutLeftLikeStream(Post post) =>
      _instance._firestore.myShoutLeftLikeStream(post);

  static Stream<DocumentSnapshot> myShoutRightLikeStream(Post post) =>
      _instance._firestore.myShoutRightLikeStream(post);
}
