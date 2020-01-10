import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:nutes/core/models/doodle.dart';
import 'package:nutes/core/services/events.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:image/image.dart' as img;
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
import 'package:provider/provider.dart';

const scrollDuration = Duration(milliseconds: 300);
const scrollCurve = Curves.easeInOut;

class Repo {
//  static bool isHomeFirst = true;
//  static ScrollPhysics physics = ClampingScrollPhysics();

  final _firestore = FirestoreService();
  final _database = RTDBProvider();
  final _storage = FIRStorage();

  static String fcmToken;

  static UserProfile auth;

  static final shared = Repo();
//  static UserProfile currentProfile;

  static Story myStory;

  static UserStory get currentUserStory => snapshot.userStories[storyIndex];
  static StorySnapshot snapshot = StorySnapshot(userStories: [], storyIndex: 0);

  static int get storyIndex => snapshot.storyIndex;
  static Story get currentStory => snapshot.userStories[storyIndex].story;

  static StreamController<StorySnapshot> storiesStreamController;
  static ScrollController storiesScrollController = ScrollController();

  static Future<List<User>> getFollowersOfUser(String uid) =>
      shared._firestore.getFollowersOfUser(uid);

  static Future<List<User>> getFollowingsOfUser(String uid) =>
      shared._firestore.getFollowingsOfUser(uid);

  static Future<List<User>> getMyUserFollowings() =>
      shared._firestore.getMyUserFollowings();

  static Future<List<Activity>> getMyActivity() =>
      shared._firestore.getMyActivity();

  static Future<List<Activity>> getMyFollowingsActivity() =>
      shared._firestore.getMyFollowingsActivity();

  static void refreshStream() {
    return storiesStreamController.add(snapshot);
  }

  static Future<List<User>> getMomentSeenBy(String ownerId, String momentId) =>
      shared._firestore.getMomentSeenBy(ownerId, momentId);

  static Future<void> setMomentAsSeen(String ownerId, String momentId) =>
      shared._firestore.setMomentAsSeen(ownerId, momentId);

  static Stream<StorySnapshot> stream() {
    storiesStreamController =
        StreamController<StorySnapshot>.broadcast(onListen: () {
      print('on listen');
      storiesStreamController.add(snapshot);
    });
    return storiesStreamController.stream;
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
    return shared._firestore.updateAccountPrivacy(isPrivate);
  }

  static Future deleteChatWithUser(User user) async {
    return shared._firestore.deleteChatWithUser(user);
  }

  static Future<Timestamp> chatEndAtForUser(String uid) {
    return shared._firestore.chatEndAtForUser(uid);
  }

  static Future<void> updateLastSeenPeerMessage(ChatItem lastMessage) =>
      shared._firestore.updateLastSeenMessage(lastMessage);

  static Future<List<ChatItem>> getInitialMessages(
      {String chatId, Timestamp endAt}) {
    return shared._firestore.getMessages(chatId, endAt);
  }

  static Future<List<ChatItem>> getMessages(
      {String chatId, Timestamp endAt, Timestamp startAt}) {
    return shared._firestore.getMessages(chatId, endAt, startAt: startAt);
  }

  static Future isTyping(String chatId, String uid, bool isTyping) {
    return shared._firestore.isTyping(chatId, uid, isTyping);
  }

  static Stream<QuerySnapshot> isTypingStream(String chatId) {
    return shared._firestore.isTypingStream(chatId);
  }

  static Stream<QuerySnapshot> DMStream() {
    return shared._firestore.DMStream();
  }

  static Future<void> deleteShout(String id) =>
      shared._firestore.deleteShout(id);

  static Stream<QuerySnapshot> ShoutStream() {
    return shared._firestore.ShoutStream();
  }

  static Stream<QuerySnapshot> messagesStream(String chatId) {
    return shared._firestore.messagesStream(chatId);
  }

//  static Stream<QuerySnapshot> messageStream(
//      String chatId, Timestamp endAt, int limit) {
//    return _instance._firestore.messageStream(chatId, endAt, limit);
//  }
//
//  static Stream<QuerySnapshot> messageStreamPaginated(
//      String chatId, Timestamp endAt, DocumentSnapshot startAfter) {
//    return _instance._firestore
//        .messageStreamPaginated(chatId, endAt, startAfter);
//  }

  static Stream<QuerySnapshot> chatStream() {
    return shared._firestore.chatStream();
  }

  static Future likeShout(bool isChallenger, Post post) async {
    return shared._firestore.likeShout(isChallenger: isChallenger, post: post);
  }

  static Future unlikeShout(bool isChallenger, Post post) async {
    return shared._firestore
        .unlikeShout(isChallenger: isChallenger, post: post);
  }

  static Future likePost(Post post) async {
    return shared._firestore.likePost(post);
  }

  static Future unlikePost(Post post) async {
//    likedPosts.remove(post.id);
//    updateLikeStream();
    return shared._firestore.unlikePost(post);
  }

  static DocumentReference createMessageRef(String chatId) {
    return shared._firestore.createMessageRef(chatId);
  }

  static completeShoutChallenge(
      {String chatId,
      String messageId,
      String content,
      String response,
      User peer}) {
    return shared._firestore
        .completeShoutChallenge(chatId, messageId, content, response, peer);
  }

  static Future uploadMessage({
    DocumentReference ref,
    Bubbles type,
    String content,
    User peer,
    Map data,
  }) {
    return shared._firestore.uploadMessage(
      messageRef: ref,
      type: type,
      content: content,
      peer: peer,
      data: data,
    );
  }

  static Future uploadStory({@required ImageFileBundle fileBundle}) async {
    final storyRef = shared._firestore.createStoryRef();

    final url = await shared._storage.uploadStoryFiles(
        storyId: storyRef.documentID, uid: auth.uid, fileBundle: fileBundle);
    return await shared._firestore.uploadStory(storyRef: storyRef, url: url);
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
    final shoutRef = shared._firestore.publicPostRef();
    final shoutId = shoutRef.documentID;

    final selfRef = shared._firestore.userPostRef(auth.uid, shoutId);

    final peerRef = shared._firestore.userPostRef(peer.uid, shoutId);

    final timestamp = Timestamp.now();

    final payload = {
      'type': 'shout',
      'uploader': auth.toMap(),
      'timestamp': timestamp,
      'data': data,
    };

    return shared._firestore.runTransaction((t) {
      t.set(shoutRef, payload);
      t.set(selfRef, payload);
      return t.set(peerRef, payload);
    });
  }

  static uploadComment({
    @required String postId,
    @required Comment comment,
  }) async {
    return shared._firestore.uploadComment(postId: postId, comment: comment);
  }

  static Future updatePost({@required Post post}) async {
    final updatedPost = post.toMap();
    print(updatedPost);

    final postRef = shared._firestore.userPostRef(post.owner.uid, post.id);

    postRef.setData(updatedPost, merge: true);
  }

  static Future<List<Doodle>> getDoodles({
    @required String postId,
  }) =>
      shared._firestore.getDoodles(postId: postId);

  static Future uploadDoodle(
      {@required String postId, @required File file}) async {
    final url = await shared._storage.uploadDoodle(postId: postId, file: file);

    await shared._firestore.uploadDoodle(postId: postId, url: url);

    return;
  }

  ///Uploads a shout as a post
  static Future uploadShoutPost({@required User peer, @required Map data}) {
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

    final batch = shared._firestore.batch();

    ///1. Set public post doc privacy field
    ///This public doc is used to maintain and query post stats(eg. like stats)

    final publicRef = shared._firestore.publicPostRef();

    final postId = publicRef.documentID;

    print('new post: $postId');

    batch.setData(publicRef, {
      'owner_id': auth.uid,
      'published': timestamp,
      'is_private': isPrivate,
    });

    ///2. set user post doc
    final myPostRef = shared._firestore.myPostRef(postId);

    var bundleMaps;

    if (fileBundles != null) {
      ///Upload files to storage
      ///and then get the storage urls
      final uploadTasks = fileBundles
          .map((b) => shared._storage
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

    final uploader = auth.user.toMap();

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
      final peerPostRef = shared._firestore.userPostRef(peer.uid, postId);
      batch.setData(peerPostRef, payload);
    }

    ///3. Cloud Functions - fanout write to followers' feeds
    ///
    /// 4?. fan out write to followers' activity

    return batch.commit();
  }

  ///current user's story stream
  static Stream<QuerySnapshot> myStoryStream() {
    return shared._firestore.myStoryStream(auth.uid);
  }

  static Future<Map<String, dynamic>> getSeenStories() =>
      shared._firestore.getSeenStories();

  static Stream<DocumentSnapshot> seenStoriesStream() =>
      shared._firestore.seenStoriesStream();

  static Future updateSeenStories(Map<String, Timestamp> data) =>
      shared._firestore.updateSeenStories(data);

  static Future<List<UserStory>> getStoriesOfFollowings(
      {List<UserStory> userStories}) {
    return shared._firestore.getStoriesOfFollowings();
  }

  static Future<Story> getStoryForUser(String uid) {
    return shared._firestore.getStoryForUser(uid);
  }

  ///fetch posts
  static Future<PostCursor> getFeed({DocumentSnapshot startAfter}) async {
    final postCursor = await shared._firestore.getFeed(startAfter: startAfter);

    return postCursor;
  }

  static Future<List> getMyFollowRequests() async {
    final doc = await shared._firestore.myFollowRequestsRef().get();

    return doc.exists ? doc['requests'] ?? [] : [];
  }

  ///Deletes a follow request
  static redactFollowRequest(String followerId, String followingId) {
    shared._firestore
        .deleteFollowRequest(follower: followerId, following: followingId);
  }

  static authorizeFollowRequest(User follower) {
    shared._firestore
        .deleteFollowRequest(follower: follower.uid, following: auth.uid);
    return shared._firestore.follow(follower: follower, following: auth.user);
  }

  static Map followingsArray = {};

  static Stream<DocumentSnapshot> myFollowingListStream() {
    return shared._firestore.myFollowingListStream();
  }

  static Stream<DocumentSnapshot> amIFollowingUserStream(String uid) {
    return shared._firestore.amIFollowingUserStream(uid);
  }

  /// follow a user
  static requestFollow(User user, bool isPrivate) {
    isPrivate
        ? shared._firestore.requestFollow(user.uid)
        : shared._firestore.follow(follower: auth.user, following: user);
  }

  /// unfollow a user
  static void unfollowUser(String uid) {
    shared._firestore.unfollow(uid);
  }

  /// check if following a user
//  static Future<bool> isFollowing({String follower, String following}) =>
//      _instance._firestore
//          .isFollowing(follower: follower, following: following);

  static Future<UserProfile> getUserProfileFromUsername(String username) =>
      shared._firestore.getUserProfileFromUsername(username);

  static Stream<DocumentSnapshot> userProfileStream(String uid) =>
      shared._firestore.userProfileStream(uid);

  static Future<UserProfile> getUserProfile(String uid) =>
      shared._firestore.getUserProfile(uid);

  static Future getRecentSearches() => shared._firestore.getRecentSearches();

  static Future deleteRecentSearch(String uid) =>
      shared._firestore.deleteRecentSearch(uid);

  static Future createRecentSearch(User user) =>
      shared._firestore.createRecentSearch(user);

  static Future<List<User>> searchUsers(String text) =>
      shared._firestore.searchUsers(text);

  static Future<bool> usernameExists(String name) =>
      shared._firestore.usernameExists(name);

  static Future<User> getUser(String uid) => shared._firestore.getUser(uid);

  static Future<void> logout() => shared._firestore.logout();

  ///returns a user object
  static Future<UserProfile> signInWithUsernameAndPassword(
      {String username, String password}) async {
    print('repo sign in $username');
    final user = await shared._firestore
        .signInWithUsernameAndPassword(username: username, password: password);

//    auth.reset();
    auth = user;

//    auth = user;

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
      throw (err);
    });

    ///create user doc on firestore
    return (authResult != null)
        ? await shared._firestore.createUser(
            uid: authResult.user.uid,
            username: username,
            email: authResult.user.email)
        : null;
  }

  static Future<UserStats> getUserStats(String uid) =>
      shared._database.getUserStats(uid);

  static Stream<QuerySnapshot> myPostStream() =>
      shared._firestore.myPostStream();

  static Future<List<Post>> getUserPosts(String uid) =>
      shared._firestore.getUserPosts(uid);

  static Future<List<User>> getPostUserLikes(Post post) =>
      shared._firestore.getPostUserLikes(post);

  static Future<PostCursor> getTrendingPosts(DocumentSnapshot startAfter) =>
      shared._firestore.getTrendingPosts(startAfter);

  static Future<PostCursor> getNewestPosts(DocumentSnapshot startAfter) =>
      shared._firestore.getNewestPosts(startAfter);

  static Future<PostCursor> getPostsForUser({
    String uid,
    int limit,
    DocumentSnapshot startAfter,
  }) async =>
      shared._firestore
          .getPostsForUser(uid: uid, limit: limit, startAfter: startAfter);

  static Comment createComment(
          {@required String text,
          @required String postId,
          Comment parentComment}) =>
      shared._firestore
          .newComment(text: text, postId: postId, parentComment: parentComment);

  static Future<List<Comment>> getComments(String postId) async =>
      shared._firestore.getComments(postId);

  ///Returns a complete post from an incomplete one
  static Future<Post> getPostStatsAndLikes(Post post) async {
    return shared._firestore.getPostStatsAndLikes(post);
  }

  ///Returns a complete post from post id
  static Future<Post> getPostComplete(String postId, String ownerId) async {
    return shared._firestore.getPostComplete(postId, ownerId);
  }

  static Future<UserProfile> removeCurrentPhoto() async {
    shared._storage.removeCurrentPhoto();
    return shared._firestore.updateProfile(urls: ImageUrlBundle.empty());
//    final updatedUser = Auth.instance.profile.copyWith(photoUrl: '');
  }

  static Future<UserProfile> updateProfile({
    String username,
    String displayName,
    String bio,
    ImageUrlBundle urls,
  }) async {
    final profile = shared._firestore.updateProfile(
        username: username, displayName: displayName, bio: bio, urls: urls);

    FirestoreService.auth = profile;

    return profile;
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

    final bundle = await shared._storage.uploadPhoto(
        uid: uid,
        fileBundle: ImageFileBundle(
            original: original,
            medium: File(mediumPath)..writeAsBytesSync(img.encodeJpg(medium)),
            small: File(smallPath)..writeAsBytesSync(img.encodeJpg(small))));

    print('bundle uploaded: $bundle');

    final profile = await shared._firestore.updateProfile(urls: bundle);

    eventBus.fire(UserProfileChangedEvent(profile));

    return profile;
  }

  static DocumentReference myRef() {
    return shared._firestore.userRef(auth.uid);
  }

  static Stream<DocumentSnapshot> myPostLikeStream(Post post) =>
      shared._firestore.myPostLikeStream(post);

  static Stream<DocumentSnapshot> myShoutLeftLikeStream(Post post) =>
      shared._firestore.myShoutLeftLikeStream(post);

  static Stream<DocumentSnapshot> myShoutRightLikeStream(Post post) =>
      shared._firestore.myShoutRightLikeStream(post);

  static void createFCMDeviceToken({String uid, String token}) =>
      shared._firestore.createFCMDeviceToken(uid: uid, token: token);
}
