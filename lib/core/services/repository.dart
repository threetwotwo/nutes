import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  static Stream<DocumentSnapshot> blockedUserStream(String uid) =>
      shared._firestore.blockedUserStream(uid);

  static Stream<DocumentSnapshot> blockedByStream() =>
      shared._firestore.blockedByStream();

  static Future<List> getBlockedBy() => shared._firestore.getBlockedBy();

  static Future<List<User>> getBlockedUsers() =>
      shared._firestore.getBlockedUsers();

  static Future<void> blockUser(User user) => shared._firestore.blockUser(user);

  static Future<void> unblockUser(User user) =>
      shared._firestore.unblockUser(user);

  static Future<void> reportPost(Post post, String type) =>
      shared._firestore.reportPost(post, type);

  static Future<void> reportProfile(User user, String type) =>
      shared._firestore.reportProfile(user, type);

  static Future<void> sendFeedback(String feedback) =>
      shared._firestore.sendFeedback(feedback);

  static Future<void> sendSupportMessage(String email, String message) =>
      shared._firestore.sendSupportMessage(email, message);

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
      String topic,
      User peer,
      String postId}) {
    return shared._firestore.completeShoutChallenge(
        chatId, messageId, content, response, peer, postId);
  }

  static Future uploadMessage({
    DocumentReference ref,
    Bubbles type,
    String content,
    User peer,
    Map data,
    String topic,
  }) {
    return shared._firestore.uploadMessage(
      messageRef: ref,
      type: type,
      content: content,
      peer: peer,
      data: data,
      topic: topic,
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

  static uploadComment({
    @required Post post,
    @required Comment comment,
  }) async {
    return shared._firestore.uploadComment(post: post, comment: comment);
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

  static Future<void> deletePost(String postId) async =>
      shared._firestore.deletePost(postId);

  static Future<void> deleteComment(String postId, String commentId) async =>
      shared._firestore.deleteComment(postId, commentId);

  ///Uploads a shout as a post
  static Future<Post> uploadShoutPost(
      {@required User peer, @required Map data}) {
    return uploadPost(
        type: PostType.shout, isPrivate: false, peer: peer, metadata: data);
  }

  static Future<Post> uploadPost({
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

    final milliSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    final daysSinceEpoch = milliSinceEpoch ~/ 86400000;

    batch.setData(publicRef, {
      'owner_id': auth.uid,
      'published': timestamp,
      'days_since_epoch': daysSinceEpoch,
      'is_private': isPrivate,
      'like_count': 0,
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

    final uploader = FirestoreService.ath.user.toMap();

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
      final shoutPayload = {
        'type': PostHelper.stringValue(type),
        'uploader': peer.toMap(),
        'timestamp': timestamp,
        'caption': caption ?? '',
        if (metadata != null) 'data': metadata,
        if (fileBundles != null) 'urls': bundleMaps,
      };
      final peerPostRef = shared._firestore.userPostRef(peer.uid, postId);
      batch.setData(peerPostRef, shoutPayload);
    }

    ///3. Cloud Functions - fanout write to followers' feeds
    ///
    /// 4?. fan out write to followers' activity
    ///
    /// 5. write to my feed
    final feedRef = myFeedRef(postId);
    batch.setData(feedRef, payload);

    await batch.commit();

    final post = Post.fromMap(payload..['post_id'] = postId);

    return post;
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

  static Future<bool> checkIfThereAreNewPosts(Timestamp timestamp) =>
      shared._firestore.checkIfThereAreNewPosts(timestamp);

  static Future<PostCursor> getNewPostsForFeed({DocumentSnapshot endAt}) async {
    final postCursor = await shared._firestore.getNewPostsForFeed(endAt);

    return postCursor;
  }

  static Stream<DocumentSnapshot> myFollowRequestStream() =>
      shared._firestore.myFollowRequestStream();

  static Future<List> getMyFollowRequests() async {
    final doc = await shared._firestore.myFollowRequestsRef().get();

    return doc.exists ? doc['requests'] ?? [] : [];
  }

  ///Deletes a follow request
  static deleteFollowRequest(String followerId, String followingId) {
    return shared._firestore
        .deleteFollowRequest(follower: followerId, following: followingId);
  }

  static authorizeFollowRequest(User follower) {
    shared._firestore.deleteFollowRequest(
        follower: follower.uid, following: FirestoreService.ath.uid);
    return shared._firestore
        .follow(follower: follower, following: FirestoreService.ath.user);
  }

  static Map followingsArray = {};

  static Stream<DocumentSnapshot> myFollowingListStream() {
    return shared._firestore.myFollowingListStream();
  }

  static Stream<DocumentSnapshot> amIFollowingUserStream(String uid) {
    return shared._firestore.amIFollowingUserStream(uid);
  }

  /// follow a user
  static requestFollow(User user) async {
    user.isPrivate
        ? shared._firestore.requestFollow(user.uid)
        : await shared._firestore.follow(follower: auth.user, following: user);

    return eventBus.fire(UserFollowEvent(user));
  }

  /// unfollow a user
  static Future<void> unfollowUser(String uid) async {
    await shared._firestore.unfollow(uid);
    return eventBus.fire(UserUnFollowEvent(uid));
  }

  /// check if following a user
//  static Future<bool> isFollowing({String follower, String following}) =>
//      _instance._firestore
//          .isFollowing(follower: follower, following: following);

  static Future<UserProfile> getUserProfileFromUsername(String username) =>
      shared._firestore.getUserProfileFromUsername(username);

  static Stream<DocumentSnapshot> userProfileStream(String uid) =>
      shared._firestore.userProfileStream(uid);

  static Stream<DocumentSnapshot> myProfileStream() =>
      shared._firestore.userProfileStream(FirestoreService.ath.uid);

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

    FirebaseMessaging().subscribeToTopic(authResult.user.uid);

    ///create user doc on firestore
    final profile = (authResult != null)
        ? await shared._firestore.createUser(
            uid: authResult.user.uid,
            username: username,
            email: authResult.user.email)
        : null;

//    if (profile != null && FirestoreService.token != null)
//      createFCMDeviceToken(profile.uid, FirestoreService.token);

    return profile;
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

  static Stream<DocumentSnapshot> commentLikeStream(
          String postId, String commentId) =>
      shared._firestore.commentLikeStream(postId, commentId);

  static Future<bool> didLikeComment(String postId, String commentId) =>
      shared._firestore.didLikeComment(postId, commentId);

  static Future<void> likeComment(Post post, Comment comment) =>
      shared._firestore.likeComment(post, comment);

  static Future<void> unlikeComment(String postId, Comment comment) =>
      shared._firestore.unlikeComment(postId, comment);

  static Comment createComment(
          {@required String text,
          @required String postId,
          Comment parentComment}) =>
      shared._firestore
          .newComment(text: text, postId: postId, parentComment: parentComment);

  static Future<CommentCursor> getComments(
          String postId, DocumentSnapshot startAfter) async =>
      shared._firestore.getComments(postId, startAfter);

  static Future<List<Comment>> getMoreReplies(
          String postId, String parentId, DocumentSnapshot startAfter) =>
      shared._firestore.getMoreReplies(postId, parentId, startAfter);

  ///Returns a complete post from an incomplete one
  static Future<Post> getPostStatsAndLikes(Post post) async {
    return shared._firestore.getPostStatsAndLikes(post);
  }

  static Future<List<Comment>> getPostTopComments(String postId,
          {int limit}) async =>
      shared._firestore.getPostTopComments(postId, limit: limit);

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
    final profile = await shared._firestore
        .updateProfile(
            username: username, displayName: displayName, bio: bio, urls: urls)
        .catchError((e) {
      throw (e);
    });

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

  static DocumentReference myFeedRef(String postId) {
    return myRef().collection('feed').document(postId);
  }

  static Stream<DocumentSnapshot> myPostLikeStream(Post post) =>
      shared._firestore.myPostLikeStream(post);

  static Stream<DocumentSnapshot> myShoutLeftLikeStream(Post post) =>
      shared._firestore.myShoutLeftLikeStream(post);

  static Stream<DocumentSnapshot> myShoutRightLikeStream(Post post) =>
      shared._firestore.myShoutRightLikeStream(post);

//  static void createFCMDeviceToken(String uid, String token) =>
//      shared._firestore.createFCMDeviceToken(uid, token);

  static Future<void> updateEmail(String email) =>
      shared._firestore.updateEmail(email).catchError((e) {
        print('HAHAHAHAHA you failed $e');
        throw (e);
      });

  static Future<Map> getMyInfo() => shared._firestore.getMyInfo();
  static Future<String> getMyEmail() => shared._firestore.getMyEmail();
}
