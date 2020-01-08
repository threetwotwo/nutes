import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:nutes/core/models/activity.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/models/doodle.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/utils/image_file_bundle.dart';

///The service that handles all reads and writes to firestore
class FirestoreService {
  static final Firestore shared = Firestore.instance;

  static UserProfile auth;

  static UserProfile get ath => FirestoreService.auth;

  final cache = LocalCache.instance;

  static User currentUser;

  String fcmToken;

  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler) async {
    return shared.runTransaction(transactionHandler);
  }

  WriteBatch batch() {
    return shared.batch();
  }

  ///Create a public postRef
  DocumentReference publicPostRef() {
    return shared.collection('posts').document();
  }

  DocumentReference postRef(String postId) =>
      shared.collection('posts').document(postId);

  DocumentReference get myProfileRef => userRef(auth.uid);

  CollectionReference get myFollowingsActivityColRef =>
      myProfileRef.collection('followings_activity');

  ///Doc reference to a user
  DocumentReference userRef(String uid) {
    return shared.collection('users').document(uid);
  }

  ///Recent activity of user
  CollectionReference activityRef(String uid) {
    return userRef(uid).collection('activity');
  }

  CollectionReference myActivityRef() {
    return activityRef(auth.uid);
  }

  DocumentReference userPostRef(String uid, String docId) {
    return userRef(uid).collection('posts').document(docId);
  }

  DocumentReference _shoutChallengeRef(String uid, String id) =>
      userRef(uid).collection('shout_challenges').document(id);

  DocumentReference _chatRef(String chatId) {
    return shared.collection('chats').document(chatId);
  }

  DocumentReference _myChatRefWithUser(String uid) {
    return userRef(auth.uid).collection('chats').document(uid);
  }

  CollectionReference _messagesRef(String chatId) {
    return shared.collection('chats').document(chatId).collection('messages');
  }

  CollectionReference _followingsRef(String uid) {
    return shared
        .collection('followings')
        .document(uid)
        .collection('followings');
  }

  DocumentReference myFollowRequestsRef() {
    return myProfileRef.collection('my_follow_requests').document('list');
  }

//  Future<bool> hasRequestedFollow(String requester, String recipient) async {
//    final ref = _followingsRef(recipient);
//
//    final doc = await ref.document(requester).get();
//
//    return doc.exists;
//  }

  CollectionReference _followRequestsRef(String uid) {
    assert(uid != null);
    return shared
        .collection('users')
        .document(uid)
        .collection('follow_requests');
  }

  DocumentReference _mySnapshotStoriesRef() {
    return userRef(auth.uid).collection('snapshots').document('stories');
  }

  CollectionReference _storiesRef(String uid) {
//    assert(uid != null);
    return shared.collection('users').document(uid).collection('stories');
  }

  CollectionReference _userPostsRef(String uid) {
    assert(uid != null);
    return shared.collection('users').document(uid).collection('posts');
  }

  CollectionReference _likesRef({String uid, String postId}) {
    assert(uid != null);
    return _userPostsRef(uid).document(postId).collection('likes');
  }

  CollectionReference _challengerLikesRef({String uid, String postId}) {
    assert(uid != null);
    return _userPostsRef(uid).document(postId).collection('challenger_likes');
  }

  CollectionReference _challengedLikesRef({String uid, String postId}) {
    assert(uid != null);
    return _userPostsRef(uid).document(postId).collection('challenged_likes');
  }

  Future<UserProfile> getUserProfileFromUsername(String username) async {
    final q = await shared
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .getDocuments();

    return q.documents.isEmpty ? null : UserProfile.fromDoc(q.documents.first);
  }

  Stream<DocumentSnapshot> userProfileStream(String uid) {
    return userRef(uid).snapshots();
  }

  Future<UserProfile> getUserProfile(String uid) async {
    final doc = await userRef(uid).get();
    return !doc.exists ? null : UserProfile.fromDoc(doc);
  }

  ///Returns user object from user doc
  Future<User> getUser(String uid) async {
    final doc = await userRef(uid).get();
    return User.fromDoc(doc);
  }

  Future<List<User>> getRecentSearches() async {
    final query = myProfileRef
        .collection('recent_searches')
        .orderBy('timestamp', descending: true)
        .limit(10);

    final snap = await query.getDocuments();

    return snap.documents.map((doc) => User.fromDoc(doc)).toList();
  }

  ///Delete user from recent_searches
  Future deleteRecentSearch(String uid) async {
    final ref = myProfileRef.collection('recent_searches').document(uid);

    return ref.delete();
  }

  ///Adds user to recent_searches
  Future createRecentSearch(User user) async {
    print('add ${user.username} to recent searches');
    final ref = myProfileRef.collection('recent_searches').document(user.uid);

    return ref.setData(
      user.toMap()..['timestamp'] = Timestamp.now(),
    );
  }

  Future<List<User>> searchUsers(String text) async {
    if (text == null) return [];
    if (text.isEmpty) return [];

    final length = text.length - 1;
    final char = text[length];

    final end = text.replaceRange(
        length, length + 1, String.fromCharCode(char.codeUnitAt(0) + 1));

    final query = shared
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: text)
        .where('username', isLessThan: end)
        .limit(6);

    final result = await query.getDocuments();

    return result.documents.map((doc) => User.fromDoc(doc)).toList();
  }

  Future<bool> usernameExists(String username) async {
    final qs = await shared
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .getDocuments();
    return qs.documents.isNotEmpty;
  }

  Future updateAccountPrivacy(bool isPrivate) async {
    final ref = shared.collection('users').document(auth.uid);

    auth = auth.copyWith(isPrivate: isPrivate);

    return ref.updateData({'is_private': isPrivate});
  }

  ///Updates the [end_at] field for the chat doc ref
  Future deleteChatWithUser(User user) async {
    final selfId = auth.uid;

    final selfRef = userRef(selfId).collection('chats').document(user.uid);

    final payload = {
      'is_persisted': false,
      'end_at': Timestamp.now(),
    };

    return selfRef.setData(payload, merge: true);
  }

  Future<Timestamp> chatEndAtForUser(String uid) async {
    final ref = _myChatRefWithUser(uid);
    final doc = await ref.get();
    if (!doc.exists) return Timestamp.fromMillisecondsSinceEpoch(100000);
    final Timestamp endAt =
        doc['end_at'] ?? Timestamp.fromMillisecondsSinceEpoch(100000);
    return endAt;
  }

  Future<void> updateLastSeenMessage(ChatItem message) {
    final batch = shared.batch();

    ///Update to my ref
    final myRef = myProfileRef.collection('chats').document(message.senderId);

    ///Update to peer ref
    final peerRef =
        userRef(message.senderId).collection('chats').document(auth.uid);

    batch.setData(myRef, {'last_seen_timestamp': message.timestamp},
        merge: true);
    batch.setData(peerRef, {'peer_last_seen_timestamp': message.timestamp},
        merge: true);

    return batch.commit();
  }

  Future<List<ChatItem>> getMessages(String chatId, Timestamp endAt,
      {Timestamp startAt}) async {
    final ref = _chatRef(chatId);

    final limit = 20;

    Query query;

    query = endAt == null
        ? query = ref
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(limit)
        : startAt == null
            ? ref
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .endAt([endAt]).limit(limit)
            : ref
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .startAfter([startAt]).endAt([endAt]).limit(limit);

    final snap = await query.getDocuments();

    return snap.documents.map((doc) => ChatItem.fromDoc(doc)).toList();
  }

  Stream<QuerySnapshot> messagesStream(String chatId) {
    return _chatRef(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

//  Stream<QuerySnapshot> messageStream(
//      String chatId, Timestamp endAt, int limit) {
//    final ref = _chatRef(chatId);
//
//    return ref
//        .collection('messages')
//        .orderBy('timestamp', descending: true)
//        .endAt([endAt])
//        .limit(limit)
//        .snapshots();
//  }
//
//  Stream<QuerySnapshot> messageStreamPaginated(
//      String chatId, Timestamp endAt, DocumentSnapshot startAfter) {
//    final ref = _chatRef(chatId);
//
//    return ref
//        .collection('messages')
//        .orderBy('timestamp', descending: true)
//        .endAt([endAt])
//        .startAfterDocument(startAfter)
//        .limit(2)
//        .snapshots();
//  }

  Future<void> deleteShout(String id) {
    final ref = myProfileRef.collection('shout_challenges').document(id);

    return ref.delete();
  }

  Stream<QuerySnapshot> ShoutStream() {
    return myProfileRef
        .collection('shout_challenges')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> DMStream() {
//    final timestamp = Timestamp.now();

//    final todayInSeconds = timestamp.seconds;
//    final todayInNanoSeconds = timestamp.nanoseconds;

    ///24 hours ago since now
//    final cutOff = Timestamp(todayInSeconds - 2628000000, todayInNanoSeconds);

    return userRef(auth.uid)
        .collection('chats')
        .where('is_persisted', isEqualTo: true)
//        .where('last_checked_timestamp', isGreaterThanOrEqualTo: cutOff)
        .snapshots();
//        .snapshots(includeMetadataChanges: true);
  }

  isTyping(String chatId, String uid, bool isTyping) {
    final ref = _chatRef(chatId).collection('is_typing');
    return isTyping
        ? ref.document(uid).setData({})
        : ref.document(uid).delete();
  }

  Stream<QuerySnapshot> isTypingStream(String chatId) {
    return _chatRef(chatId).collection('is_typing').snapshots();
  }

  Stream<QuerySnapshot> chatStream() {
    return shared
        .collection('chats')
        .where('persist_${auth.uid}', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  ///Retrieves uids of people that current user is chatting with
  ///Returns nothing if there are no messages in the chat document
  Stream<List<String>> getChatRecipientIds() {
    final qsStream = shared
        .collection('chats')
        .where('participants', arrayContains: auth.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();

    final x = qsStream.map((qs) => qs.documents.map((ds) {
          return (ds.data['participants'] as List<String>)
              .firstWhere((p) => p != auth.uid);
        }));

    return x;
  }

  ///Where should i put this? Do I even need this?
  ///Dont do anything if there are no messages
  Future resolveParticipants(
      String chatId, Timestamp timestamp, User recipient) async {
    final senderId = auth.uid;
    final recipientId = recipient.uid;

    Map senderMap = {'timestamp': timestamp};
    senderMap.addAll(auth.toMap());

    Map recipientMap = {'timestamp': timestamp};
    recipientMap.addAll(recipient.toMap());

    final chatRef = _chatRef(chatId);
    final chatSnap = await chatRef.get();

    if (!chatSnap.exists) {
      chatRef.setData({
        'participants': [senderId, recipientId],
        'persist_$senderId': true,
        'persist_$recipientId': true,
        senderId: senderMap,
        recipientId: recipientMap,
        'timestamp': timestamp,
      });
    }
  }

  ///updates the timestamp of a chat doc whenever there's an activity
  ///can be done within cloud functions
  Future updateChatLastChecked(String chatId, Map data) async {
    final snap = await _chatRef(chatId).get();
    if (!snap.exists) return;

    _chatRef(chatId).updateData({
      'timestamp': Timestamp.now(),
      'last_checked': data,
      'persist_${auth.uid}': true,
    });
  }

  DocumentReference createMessageRef(String chatId) {
    return _messagesRef(chatId).document();
  }

  Future<void> completeShoutChallenge(
    String chatId,
    String messageId,
    String content,
    String response,
    User peer,
  ) {
    ///Update shout message in chat ref by adding metadata response and
    ///updated timestamp
    ///Update last_checked for both chat participants
    final timestamp = Timestamp.now();

    final messageRef =
        _chatRef(chatId).collection('messages').document(messageId);

    final selfRef = userRef(auth.uid).collection('chats').document(peer.uid);

    final peerRef = userRef(peer.uid).collection('chats').document(auth.uid);

    final selfMap = auth.toMap();

    ///Auto updates the peer info
    final peerMap = peer.toMap();

    final payload = {
      'sender_id': auth.uid,
      'timestamp': timestamp,
      'content': response,
      'type': BubbleHelper.stringValue(Bubbles.shout_complete),
      'metadata': {'responding_to': content},
    };

    final batch = shared.batch();

    ///Public chat ref
    batch.setData(messageRef, payload);

    ///My ref
    batch.setData(selfRef, {
      'is_persisted': true,
      'last_checked': payload,
      'last_checked_timestamp': timestamp,
      'user': peerMap,
    });

    ///Delete shout challenge from my ref
    batch.delete(_shoutChallengeRef(auth.uid, messageId));

    ///Peer ref
    batch.setData(peerRef, {
      'is_persisted': true,
      'last_checked': payload,
      'last_checked_timestamp': timestamp,
      'user': selfMap,
    });

    return batch.commit();
  }

  Future<List<Doodle>> getDoodles({@required String postId}) async {
    final ref = postRef(postId)
        .collection('doodles')
        .limit(8)
        .orderBy('timestamp', descending: true);

    final docs = await ref.getDocuments();

    return docs.documents.map((doc) => Doodle.fromDoc(doc)).toList();
  }

  Future<void> uploadDoodle(
      {@required String postId, @required String url}) async {
    final ref = postRef(postId).collection('doodles').document(auth.uid);

    return ref.setData({
      'owner': auth.user.toMap(),
      'url': url,
      'timestamp': Timestamp.now(),
    });
  }

  ///Uploads message to the chat ref
  ///
  ///Updates the last_checked of both chat participants
  ///
  ///[last_checked_timestamp] field is used to query the stream for the
  ///Direct Message Stream
  ///
  /// update [is_persisted] field to true so as to persist the chat in
  /// DM
  /// Stream
  Future<void> uploadMessage({
    DocumentReference messageRef,
    Bubbles type,
    String content,
    User peer,
    Map data,
  }) async {
    final timestamp = Timestamp.now();

    final selfRef = userRef(auth.uid).collection('chats').document(peer.uid);

    final peerRef = userRef(peer.uid).collection('chats').document(auth.uid);

    final selfMap = auth.user.toMap();

    ///Auto updates the peer info
    final peerMap = peer.toMap();

    final payload = {
      'sender_id': auth.uid,
      'timestamp': timestamp,
      'content': content,
      'type': BubbleHelper.stringValue(type),
      if (data != null) 'metadata': data,
    };

    final batch = shared.batch();

    ///Public chat ref
    batch.setData(messageRef, payload);

    ///My chat ref
    batch.setData(
        selfRef,
        {
          'is_persisted': true,
          'last_checked': payload,
          'last_checked_timestamp': timestamp,
          'user': peerMap,
        },
        merge: true);

    ///Peer chat ref
    batch.setData(
        peerRef,
        {
          'is_persisted': true,
          'last_checked': payload,
          'last_checked_timestamp': timestamp,
          'user': selfMap,
        },
        merge: true);

    ///Add to peer's shout challenge ref
    if (type == Bubbles.shout_challenge)
      batch.setData(_shoutChallengeRef(peer.uid, messageRef.documentID),
          payload..putIfAbsent('user', () => selfMap));

    return batch.commit();
  }

  UserProfile updateProfile({
    String username,
    String displayName,
    String bio,
    ImageUrlBundle urls,
  }) {
    shared.collection('users').document(auth.uid).updateData({
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (urls != null) 'photo_url': urls.original,
      if (urls != null) 'photo_url_medium': urls.medium,
      if (urls != null) 'photo_url_small': urls.small,
    });

    final profile = auth.copyWith(
        username: username, displayName: displayName, bio: bio, bundle: urls);

    return profile;
  }

  updatePhotoUrl({@required String uid, @required String url}) {
    shared.collection('users').document(uid).updateData({'photo_url': url});
  }

  Future getMyFollowRequests() {}

  ///Writes a follow request doc on a given user's follow request collection
  Future requestFollow(String uid) {
    final batch = shared.batch();
    final ref = _followRequestsRef(uid).document(auth.uid);
    final ref2 = myFollowRequestsRef();

    batch.setData(
      ref,
      {
        'user': auth.toMap(),
        'timestamp': Timestamp.now(),
      },
      merge: true,
    );

    batch.setData(ref2, {
      'requests': FieldValue.arrayUnion([uid]),
    });
    return batch.commit();
  }

  ///Deletes existing follow request
  Future deleteFollowRequest(
      {@required String follower, @required String following}) {
    final batch = shared.batch();
    final ref = _followRequestsRef(following).document(follower);

    batch.delete(ref);
    batch.setData(
      myFollowRequestsRef(),
      {
        'requests': FieldValue.arrayRemove([following]),
      },
      merge: true,
    );

    return batch.commit();
  }

  /// Creates a follow relationship between follower and followed
  Future<void> follow(
      {@required User follower, @required User following}) async {
    final followerRef = shared.collection('users').document(follower.uid);
    final followingRef = shared.collection('users').document(following.uid);

    ///Current timestamp
    final timestamp = Timestamp.now();

    ///Use a batch operation since there are multiple write ops;
    final batch = shared.batch();

    ///1. Update follower's followings list
    /// should return error if full

    final followerFollowings =
        await followerRef.collection('followings_list').document('list').get();

    final followerFollowingsDetailed = await followerRef
        .collection('followings_list')
        .where('is_full', isEqualTo: false)
        .limit(1)
        .getDocuments();

    ///TODO: how to detect if doc is full

    Map followings = followerFollowingsDetailed.documents.isEmpty
        ? {}
        : followerFollowingsDetailed.documents.first.data['users'] ?? {};

    followings[following.uid] = following.toMap();

    final followingsDetailedRef = followerFollowingsDetailed.documents.isEmpty
        ? followerRef.collection('followings_list').document()
        : followerFollowingsDetailed.documents.first.reference;

    batch.setData(
        followingsDetailedRef,
        {
          'type': 'users',
          'users': followings,
          'is_full': followings.length > 999
        },
        merge: true);

    final List uids =
        !followerFollowings.exists ? [] : followerFollowings.data['uids'] ?? [];

    if (uids.length > 7500) print('full followings');

    batch.setData(
      followerFollowings.reference,
      {
        'uids': FieldValue.arrayUnion([following.uid]),
      },
      merge: true,
    );

    ///2. Add new doc to followers' followings collection
    final followerFollowingRef =
        followerRef.collection('followings').document(following.uid);

    batch.setData(
        followerFollowingRef,
        {
          'following': following.toMap(),
          'following_id': following.uid,
          'timestamp': timestamp,
        },
        merge: true);

    //3. Add new doc to following's followers collection
    final followingFollowerRef =
        followingRef.collection('followers').document(follower.uid);

    batch.setData(
      followingFollowerRef,
      {
        'follower_id': follower.uid,
        'username': follower.username,
        'timestamp': timestamp,
      },
      merge: true,
    );

    ///4. (Cloud function) increment following's follower count
    ///4b. update following's activity feed (some guy started following you)
    ///4c. fan out follow activity to follower's followers
    ///5. (Cloud function) increment follower's following count
    ///
    ///6. (Cloud function) Write following's recent posts to follower's feed
    ///
    batch.commit();

    ///2a. Add recent posts to follower feed
    return addRecentPostsToFollowerFeed(follower.uid, following.uid);
  }

  Future addRecentPostsToFollowerFeed(
      String followerId, String followingId) async {
    ///TODO: add end at
    final followingPostsRef = userRef(followingId)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(10);

    final followerFeedRef = userRef(followerId).collection('feed');

    final docs = await followingPostsRef.getDocuments();

    final batch = shared.batch();

    docs.documents.forEach((doc) =>
        batch.setData(followerFeedRef.document(doc.documentID), doc.data));

    return batch.commit();
  }

  Future deleteRecentPostsToFollowerFeed(
      String followerId, String followingId) async {
    final followingPostsRef = userRef(followingId)
        .collection('posts')
        .where('uploader.uid', isEqualTo: followingId);
    final followerFeedRef = userRef(followerId).collection('feed');

    final docs = await followingPostsRef.getDocuments();

    final batch = shared.batch();

    docs.documents.forEach(
        (doc) => batch.delete(followerFeedRef.document(doc.documentID)));

    return batch.commit();
  }

  unfollow(String uid) async {
    ///Follower user Ref
    final followerRef = shared.collection('users').document(auth.uid);

    ///Followed user ref
    final followedRef = shared.collection('users').document(uid);

    ///Use a batch operation since there are multiple write ops;
    final batch = shared.batch();

    ///1. Update follower's followings list

    final myRef = myFollowingListRef();

    final followerFollowingsDetailed = await followerRef
        .collection('followings_list')
        .where('users.$uid.uid', isEqualTo: uid)
        .limit(1)
        .getDocuments();

    Map followings = followerFollowingsDetailed.documents.isEmpty
        ? {}
        : followerFollowingsDetailed.documents.first.data['users'] ?? {};

    followings.remove(uid);

    final followingsRef = followerFollowingsDetailed.documents.isEmpty
        ? null
        : followerFollowingsDetailed.documents.first.reference;

    if (followingsRef != null)
      batch.updateData(followingsRef, {'users': followings, 'is_full': false});

    batch.setData(
      myRef,
      {
        'uids': FieldValue.arrayRemove([uid]),
      },
      merge: true,
    );

    ///2. Delete doc in followers' followings collection
    final followerFollowingRef =
        followerRef.collection('followings').document(uid);

    batch.delete(followerFollowingRef);

    //3. Delete doc in following's followers collection
    final followingFollowerRef =
        followedRef.collection('followers').document(auth.uid);

    batch.delete(followingFollowerRef);

    ///4. (Cloud function) decrement following's follower count
    ///5. (Cloud function) decrement follower's following count
    ///
    ///6. (Cloud function) delete following's recent posts from follower's feed
    ///
    batch.commit();

    ///2a. Delete recent posts from follower feed
    return deleteRecentPostsToFollowerFeed(auth.uid, uid);
  }

  Stream<QuerySnapshot> myStoryStream(String uid) {
    final timestamp = Timestamp.now();

    final todayInSeconds = timestamp.seconds;
    final todayInNanoSeconds = timestamp.nanoseconds;

    ///24 hours ago since now
    final cutOff = Timestamp(todayInSeconds - 86400, todayInNanoSeconds);

    return _storiesRef(uid)
        .where('timestamp', isGreaterThanOrEqualTo: cutOff)
        .snapshots();
  }

  DocumentReference myFollowingListRef() {
    return shared
        .collection('users')
        .document(auth.uid)
        .collection('followings_list')
        .document('list');
  }

  Stream<DocumentSnapshot> myFollowingListStream() {
    return myFollowingListRef().snapshots();
  }

  Future<Map<String, dynamic>> getSeenStories() async {
    final ref = myProfileRef.collection('seen_stories').document('list');

    final doc = await ref.get();

    return doc.data ?? {};
  }

  Stream<DocumentSnapshot> seenStoriesStream() =>
      myProfileRef.collection('seen_stories').document('list').snapshots();

  Future updateSeenStories(Map<String, Timestamp> data) async {
    final now = Timestamp.now();

    final todayInSeconds = now.seconds;
    final todayInNanoSeconds = now.nanoseconds;

    ///24 hours ago since now
    final cutOff = Timestamp(todayInSeconds - 86400, todayInNanoSeconds);

    final ref = myProfileRef.collection('seen_stories').document('list');

    final doc = await ref.get();

    final stories = doc.data ?? {};

    ///Remove old data
    stories.removeWhere((k, v) => v.seconds < cutOff.seconds);

    stories.addAll(data);

    return ref.setData(stories);
  }

  Future<List<User>> getMomentSeenBy(String ownerId, String momentId) async {
    final query = momentRef(ownerId, momentId).collection('seen_by');

    final snap = await query.getDocuments();

    print('moment $momentId seen by ${snap.documents.length}');
    return snap.documents
        .map((doc) => User.fromMap(doc['owner'] ?? {}))
        .toList();
  }

  Future<void> setMomentAsSeen(String ownerId, String momentId) async {
    print('set moment $momentId as seen by ${auth.uid}');
    final ref =
        momentRef(ownerId, momentId).collection('seen_by').document(auth.uid);

    print(ref.path);
    final payload = {
      'timestamp': Timestamp.now(),
      'owner': auth.user.toMap(),
    };
    return ref.setData(payload, merge: true);
  }

  Future<List<UserStory>> getStoriesOfFollowings() async {
    final now = Timestamp.now();

    final todayInSeconds = now.seconds;
    final todayInNanoSeconds = now.nanoseconds;

    ///24 hours ago since now
    final cutOff = Timestamp(todayInSeconds - 86400, todayInNanoSeconds);

    final query = myProfileRef
        .collection('story_feed')
        .where('timestamp', isGreaterThanOrEqualTo: cutOff);

    final snap = await query.getDocuments();

    return snap.documents.map((doc) => UserStory.fromDoc(doc)).toList();
  }

  Future<Story> getStoryForUser(String uid) async {
    final storiesRef = _storiesRef(uid);

    final now = Timestamp.now();

    final todayInSeconds = now.seconds;
    final todayInNanoSeconds = now.nanoseconds;

    ///24 hours ago since now
    final cutOff = Timestamp(todayInSeconds - 86400, todayInNanoSeconds);
    final snaps = await storiesRef
        .where('timestamp', isGreaterThanOrEqualTo: cutOff)
        .getDocuments();
    final moments = snaps.documents.map((ds) => Moment.fromDoc(ds)).toList();
    final story = Story(
      moments: moments,
    );
    return story;
  }

  Comment newComment(
      {@required String text, @required String postId, Comment parentComment}) {
    final ref = shared
        .collection('posts')
        .document(postId)
        .collection('comments')
        .document();

    return Comment(
      id: ref.documentID,
      text: text,
      timestamp: Timestamp.now(),
      owner: auth.user,
      parentId: parentComment?.id ?? null,
      parentOwner: parentComment?.owner ?? null,
    );
  }

  Future<List<Comment>> getComments(String postId) async {
    ///1. get root comments
    ///2. get comment replies (if any)
    final commentsRef = shared
        .collection('posts')
        .document(postId)
        .collection('comments')
        .where('parent_id', isEqualTo: 'root')
        .orderBy('like_count', descending: true)
        .limit(16);

    final docs = await commentsRef.getDocuments();

    return docs.documents.map((doc) => Comment.fromDoc(doc)).toList();
  }

  Future uploadComment({
    @required String postId,
    @required Comment comment,

//                         @required User owner,
//    @required String text,
//    String parentId,
  }) async {
    final postRef = shared.collection('posts').document(postId);
    final commentRef = postRef.collection('comments').document();

//    final timestamp = Timestamp.now();

    final batch = shared.batch();

    final commentPayload = {
      'parent_id': comment.parentId ?? 'root',
      'owner': comment.owner.toMap(),
      'text': comment.text,
      'published': comment.timestamp,
      'like_count': 0,
    };

    batch.setData(commentRef, commentPayload);

    batch.setData(
      postRef,
      {
        'comment_count': FieldValue.increment(1),
      },
      merge: true,
    );

    return batch.commit();
  }

  Future uploadStory(
      {@required DocumentReference storyRef, @required String url}) async {
    return await storyRef.setData({
      'timestamp': Timestamp.now(),
      'url': url,
      'uploader': auth.user.toMap(),
    });
  }

  DocumentReference momentRef(String ownerId, String momentId) {
    final ref = shared
        .collection('users')
        .document(ownerId)
        .collection('stories')
        .document(momentId);
    return ref;
  }

  DocumentReference createStoryRef() {
    final ref = shared
        .collection('users')
        .document(auth.uid)
        .collection('stories')
        .document();
    return ref;
  }

  DocumentReference myPostRef(String id) {
    final ref = shared
        .collection('users')
        .document(auth.uid)
        .collection('posts')
        .document(id);
    return ref;
  }

  DocumentReference createUserPostRef() {
    final ref = shared
        .collection('users')
        .document(auth.uid)
        .collection('posts')
        .document();
    return ref;
  }

//  Future<bool> didLikeChallenger(Post post) async {
//    final ref = shared
//        .collection('posts')
//        .document(post.id)
//        .collection('challenger_likes')
//        .document(Repo.currentUser.uid);
//    final snap = await ref.get();
//    return snap.exists;
//  }
//
//  Future<bool> didLikeChallenged(Post post) async {
//    final ref = shared
//        .collection('media')
//        .document(post.id)
//        .collection('challenged_likes')
//        .document(Repo.currentUser.uid);
//    final snap = await ref.get();
//    return snap.exists;
//  }

  Future likeShout({@required bool isChallenger, @required Post post}) async {
    final collectionName =
        isChallenger ? 'shout_left_likes' : 'shout_right_likes';

    final ref = postRef(post.id).collection(collectionName).document(auth.uid);

    final timestamp = Timestamp.now();

    return ref.setData(
      {
        'timestamp': timestamp,
        'liker_id': auth.uid,
      }..addAll(post.toMap()),
    );
  }

  Future unlikeShout({@required bool isChallenger, @required Post post}) async {
    final collectionName =
        isChallenger ? 'shout_left_likes' : 'shout_right_likes';

    final ref = postRef(post.id).collection(collectionName).document(auth.uid);

    return ref.delete();
  }

  Future likeChallenger(bool like, Post post) async {
    final data = post.metadata;

    final String challengerId = data['challenger']['uid'];
    final String challengedId = data['challenged']['uid'];

    final uid = auth.uid;

    final challengerRef =
        _challengerLikesRef(uid: challengerId, postId: post.id).document(uid);
    final challengedRef =
        _challengerLikesRef(uid: challengedId, postId: post.id).document(uid);

    final timestamp = Timestamp.now();

    final load = {"timestamp": timestamp};

    like
        ? shared.runTransaction((t) {
            t.set(challengerRef, load);
            return t.set(challengedRef, load);
          })
        : shared.runTransaction((t) {
            t.delete(challengerRef);
            return t.delete(challengedRef);
          });
  }

//  Future<EngagementHandler> engagementHandler(
//      String key, Post post, Timestamp timestamp, bool isDestructive) async {
//    ///update engagement activity
////    final engRef = engagementRef();
//
//    final doc = await engRef.get();
//
//    final Map map = (doc.exists) ? doc[key] ?? {} : {};
//
//    isDestructive
//        ? map.remove(post.id)
//        : map[post.id] = {'timestamp': timestamp};
//
//    final payload = {key: map};
//
//    return EngagementHandler(doc.exists, payload);
//  }

  ///update post_stats via cloud functions
  Future likePost(Post post) async {
    //Shout
    final postRef = shared.collection('posts').document(post.id);

    final timestamp = Timestamp.now();

    final batch = shared.batch();

    ///1. write to post's likes collection
    final likeDocRef = postRef.collection('likes').document(auth.uid);

    final payload = {
      'timestamp': timestamp,
      'liker': auth.user.toMap(),
    }..addAll(post.toMap());

    batch.setData(
      likeDocRef,
      payload,
    );

    ///Write to owner's activity ref
    final ownerActivityRef =
        activityRef(post.owner.uid).document('${auth.uid}-${post.id}');

    batch.setData(
        ownerActivityRef, payload..addAll({'activity_type': 'post_like'}));

    ///Due to potential scalability issues ,
    ///might need to write this to my_likes col ref instead
    ///that way, you can easily query for your like plus your following likes
    /// for the post
    ///
    /// Idea for Reactive UI : use a custom stream in repo where every like
    /// event gets broadcasted and UI that is connected to the stream reacts
    /// accordingly
    ///
    /// queries to display didlike:
    /// a. check if current user has liked the post(if post has been seen)
    /// b. check (up to 3) if followings did like the post
    ///
    ///2. write to my likes doc (for didlike stream)
    ///
    ///Write left and right like here as well to reduce read counts!!!

    ///3. (Cloud function) update post like count
    ///4. (Cloud function) write to my followers' followings' likes feed

//    postRef.setData({'like_count': FieldValue.increment(1)}, merge: true);

    return batch.commit();
  }

  Future unlikePost(Post post) async {
    final likeRef = postRef(post.id).collection('likes').document(auth.uid);

    final batch = shared.batch();

//    postRef.setData({'like_count': FieldValue.increment(-1)}, merge: true);

//    final myPostLikesColRef =
//        myProfileRef.collection('my_post_likes').document(post.id);

//    batch.setData(
//        myPostLikesColRef,
//        {
//          'likes': FieldValue.arrayRemove(['post'])
//        },
//        merge: true);

    final myLikesDocRef =
        myProfileRef.collection('activity').document('post_likes');

    ///1. delete from post's likes collection
    ///2. delete from my likes doc
    ///3. (Cloud function) update post like count
    ///4. (Cloud function) delete from my followers' followings' likes feed
    batch.setData(
        myLikesDocRef,
        {
          'likes': FieldValue.arrayRemove([post.id])
        },
        merge: true);

    final ownerActivityRef =
        activityRef(post.owner.uid).document('${auth.uid}-${post.id}');

    batch.delete(likeRef);

    ///delete from owner's activity ref
    batch.delete(ownerActivityRef);

    return batch.commit();
  }

  ///TODO: how to get didlikes and stats?
  Stream<QuerySnapshot> myPostStream() {
    final ref = userRef(auth.uid)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(1);
    return ref.snapshots();
  }

  Future<List<User>> getPostUserLikes(Post post) async {
    final likeColRef = shared
        .collection('posts')
        .document(post.id)
        .collection('likes')
        .limit(10);

    final docs = await likeColRef.getDocuments();

    final futures =
        docs.documents.map((doc) => getUser(doc.documentID)).toList();

    return Future.wait(futures);
  }

  Future<List<Post>> getUserPosts(String uid) async {
    final ref =
        userRef(uid).collection('posts').orderBy('timestamp', descending: true);
    final docs = await ref.getDocuments();
    var result = docs.documents.map((doc) => Post.fromDoc(doc)).toList();
    result.removeWhere((r) => r == null);
    return result;
  }

  Future<Post> getPost(String postId, String ownerId) async {
    final query = _userPostsRef(ownerId).document(postId);

    final doc = await query.get();

    return Post.fromDoc(doc);
  }

  Future<PostCursor> getPostsForUser(
      {String uid, int limit = 10, DocumentSnapshot startAfter}) async {
    List<Post> posts = [];

    final query = startAfter == null
        ? _userPostsRef(uid)
            .limit(limit)
            .orderBy('timestamp', descending: true)
            .getDocuments()
        : _userPostsRef(uid)
            .startAfterDocument(startAfter)
            .limit(limit)
            .orderBy('timestamp', descending: true)
            .getDocuments();

    final snap = await query;

    final docs = snap.documents;

    posts.addAll(docs.map((doc) => Post.fromDoc(doc)).toList());

    ///Remove bad posts
    posts.removeWhere((post) => post == null);

    final result = await getPostsComplete(posts);

    return docs.isNotEmpty
        ? PostCursor(result, docs.last)
        : PostCursor(result, startAfter);
  }

  Future<PostCursor> getNewestPosts(DocumentSnapshot startAfter) async {
    final statsColRef = startAfter == null
        ? shared
            .collection('posts')
            .orderBy('published', descending: true)
            .limit(10)
        : shared
            .collection('posts')
            .orderBy('published', descending: true)
            .startAfterDocument(startAfter)
            .limit(10);

    final docs = await statsColRef.getDocuments();

    final stats = docs.documents.map((doc) => PostStats.fromDoc(doc)).toList();

    stats.removeWhere((s) => s.ownerId == null || s.ownerId.isEmpty);

    var result = List<Post>.from(await getPostsFromStats(stats));

    result.removeWhere((p) => (p == null || p.id == null || p.type == null));

    return docs.documents.isNotEmpty
        ? PostCursor(result, docs.documents.last)
        : PostCursor(result, startAfter);
  }

  Future<PostCursor> getTrendingPosts(DocumentSnapshot startAfter) async {
    ///Query with pagination, if any
    final query = startAfter == null
        ? shared
            .collection('posts')
            .orderBy('like_count', descending: true)
            .limit(10)
        : shared
            .collection('posts')
            .orderBy('like_count', descending: true)
            .startAfterDocument(startAfter)
            .limit(10);

    final docs = await query.getDocuments();

    ///Get list of post stats from retrieved documents
    final stats = docs.documents.map((doc) => PostStats.fromDoc(doc)).toList();

    ///Remove broken stats
    stats.removeWhere((s) => s.ownerId == null || s.ownerId.isEmpty);

    var result = List<Post>.from(await getPostsFromStats(stats));

    result.removeWhere((p) => (p == null || p.id == null || p.type == null));

    return docs.documents.isNotEmpty
        ? PostCursor(result, docs.documents.last)
        : PostCursor(result, startAfter);
  }

  ///
  /// Note: a query is counted as 1 read if no doc is returned(see Firestore
  /// Pricing)
  ///
  ///
  ///Number of required reads:
  ///
  ///1. post body(details, eg. caption, urls, etc) from user feed doc ref
  ///2. post stats from public ref
  ///3. my followings likes (up to 3)
  ///4. my post like stream
  ///5. if shout, left and right did likes streams
  ///6. top comments(max 2)
  ///
  /// min reads = 5 (text) 7 (shout), max = 8 (text), 10(shout)
  Future<PostCursor> getFeed({DocumentSnapshot startAfter}) async {
    final query = startAfter == null
        ? userRef(auth.uid)
            .collection('feed')
            .orderBy('timestamp', descending: true)
            .limit(8)
        : userRef(auth.uid)
            .collection('feed')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .startAfterDocument(startAfter);

    final docs = await query.getDocuments();

    List<Post> posts = docs.documents.map((doc) => Post.fromDoc(doc)).toList();

    final result = List<Post>.from(await getPostsComplete(posts))
      ..removeWhere((p) => p == null);

    print('${result.length} posts fetched');

    return docs.documents.isNotEmpty
        ? PostCursor(result, docs.documents.last)
        : PostCursor(result, startAfter);
  }

  Future<List<Activity>> getMyActivity() async {
    final query = activityRef(auth.uid)
//        .where('activity_type', isEqualTo: 'post_like')
        .orderBy('timestamp', descending: true)
        .limit(30);

    final docs = await query.getDocuments();

    return docs.documents.map((doc) => Activity.fromDoc(doc)).toList()
      ..removeWhere((ac) => ac.activityType == null);
  }

  Future<List<Activity>> getMyFollowingsActivity() async {
    final query = myFollowingsActivityColRef
//        .where('activity_type', isEqualTo: 'post_like')
        .orderBy('timestamp', descending: true)
        .limit(30);

    final docs = await query.getDocuments();

    return docs.documents.map((doc) => Activity.fromDoc(doc)).toList()
      ..removeWhere((ac) => ac.activityType == null);
  }

//  Future<List<Activity>> getFollowingsActivity(List<User> followings) async {
//    final query = myFollowingsActivityColRef
//        .where('type', isEqualTo: 'post_like')
//        .orderBy('timestamp', descending: true)
//        .limit(30);
//
//    final docs = await query.getDocuments();
//
//    return docs.documents
//        .map((doc) => Activity.fromDoc(doc, followings))
//        .toList();
//  }

  Future<List<User>> getFollowersOfUser(String uid) async {
    final docs =
        await userRef(uid).collection('followers').limit(20).getDocuments();

    final futures =
        docs.documents.map((doc) => getUser(doc.documentID)).toList();

    return Future.wait(futures);
  }

  Future<List<User>> getFollowingsOfUser(String uid) async {
    final docs =
        await userRef(uid).collection('followings').limit(20).getDocuments();

    final futures =
        docs.documents.map((doc) => getUser(doc.documentID)).toList();

    var result = await Future.wait(futures);

//    result.toList(growable: false);
//    result.removeWhere((u) => u == null);

    return List.from(result)..removeWhere((u) => u == null);
  }

  Future<List<User>> getMyUserFollowings() async {
    final docs = await myProfileRef
        .collection('followings_list')
        .where('type', isEqualTo: 'users')
        .getDocuments();

    final s = [];
    docs.documents.forEach((doc) =>
        (doc.data['users'] as Map).values.forEach((map) => s.add(map)));
//        .map((m) => m.values);

    return s.map((u) => User.fromMap(u)).toList();
  }

  Future<List<User>> getFollowingLikesOfPost(
      String postId, List<User> userFollowings) async {
    if (userFollowings.isEmpty || userFollowings == null) return [];

    final query = myFollowingsActivityColRef
        .where('post_id', isEqualTo: postId)
        .where('type', isEqualTo: 'post_like')
        .limit(3);

    final docs = await query.getDocuments();

    final uids = docs.documents.map((doc) {
      return doc.data['owner_id'] ?? '';
    }).toList();

    final users = uids
        .map((uid) => userFollowings.firstWhere((user) => user.uid == uid,
            orElse: () => null))
        .toList();

    users.removeWhere((user) => user == null);
    return users;
  }

  ///Return a list of posts complete with post details(image urls, etc) from a list of stats
  Future<List<Post>> getPostsFromStats(List<PostStats> stats) async {
    final futures = stats.map((st) async {
      final result = await getPost(st.postId, st.ownerId);

      final post = result?.copyWith(stats: st);

      return post;
    }).toList();

    return Future.wait(futures);
  }

  Future<Post> getPostComplete(String postId, String ownerId) async {
    final userFollowings = await getMyUserFollowings();

    print('getting post complete for post: $postId, owner: $ownerId');

    final post = await getPost(postId, ownerId);

    return post.copyWith(
      topComments: await getPostTopComments(post.id),
      stats: await getPostStats(post.id),
//      myLikes: await getMyLikesForPost(post.id),
      myFollowingLikes: await getFollowingLikesOfPost(post.id, userFollowings),
    );
  }

  Future<Post> getPostStatsAndLikes(Post post) async {
    final userFollowings = await getMyUserFollowings();

    return post.copyWith(
      stats: await getPostStats(post.id),
      myFollowingLikes: await getFollowingLikesOfPost(post.id, userFollowings),
    );
  }

  Future<List<Post>> getPostsComplete(List<Post> posts) async {
    final userFollowings = await getMyUserFollowings();

    ///remove null posts
    posts.removeWhere((p) => p == null);

    final futures = posts.map((p) async {
      return p.copyWith(
        topComments: await getPostTopComments(p.id),
        stats: await getPostStats(p.id),
        myFollowingLikes: await getFollowingLikesOfPost(p.id, userFollowings),
      );
    }).toList();

    final result = await Future.wait(futures);
    return result;
  }

  Future<UserProfile> createUser({
    @required uid,
    @required String username,
    @required String email,
  }) async {
    print('sign up $username');

    ///create new user doc using uid as doc id
    final userRef = shared.collection('users').document(uid);

    final privateInfoRef = userRef.collection('private').document('info');

    final user2 = UserProfile(
      uid: uid,
      user: User(
          uid: uid,
          username: username,
          displayName: '',
//          photoUrl: '',
          urls: ImageUrlBundle.empty(),
          isPrivate: false),
      stats: UserStats(postCount: 0, followerCount: 0, followingCount: 0),
      bio: '',
      isVerified: false,
    );

    final b = batch();

    b.setData(userRef, user2.toMap());
    b.setData(privateInfoRef, {'email': email});

    await b.commit();
//    userRef.setData(
//      user2.toMap(),
//    );
//
//    privateInfoRef.setData({
//      'email': email,
//    });

    return user2;
  }

  Future<void> logout() async {
    ///Remove FCM token from user ref
    if (auth.uid != null && fcmToken != null)
      deleteFCMToken(uid: auth.uid, token: fcmToken);

    ///Sign out via FIRAuth
    await FirebaseAuth.instance.signOut();

//    auth.reset();
  }

  Future<UserProfile> signInWithUsernameAndPassword(
      {String username, String password}) async {
    ///check if username exists
    print('signing in $username');
    final snap = await shared
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .getDocuments();

    if (snap.documents.isEmpty) return null;

    final doc = snap.documents.first;

    String email;

    ///get email associated with username
    email = doc['email'];

    if (email == null ?? email.isEmpty) {
      final info =
          await doc.reference.collection('private').document('info').get();

      email = info['email'] ?? '';
    }

    ///check if email matches with password entered
    ///

    print('FIR sign in for uid ${doc.documentID}, data: ${doc.data}');

    final authenticatedUser = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((err) {
      print(err);
      throw (err);
    });

//      ///return user object
    if (authenticatedUser != null)
      return UserProfile.fromDoc(snap.documents.first);

    return null;
  }

  Future<List<Comment>> getPostTopComments(String postId) async {
    final ref = shared
        .collection('posts')
        .document(postId)
        .collection('comments')
        .orderBy('like_count', descending: true)
        .limit(2);

    final docs = await ref.getDocuments();

    return docs.documents.map((doc) => Comment.fromDoc(doc)).toList();
  }

  Future<PostStats> getPostStats(String id) async {
    final ref = shared.collection('posts').document(id);

    final doc = await ref.get();

    return !doc.exists ? PostStats.empty(id) : PostStats.fromDoc(doc);
  }

  ///Check if current user has liked a post
  ///Returns a stream, such that didLike = snapshot.data.exists
  Stream<DocumentSnapshot> myPostLikeStream(Post post) {
    final ref = postRef(post.id).collection('likes').document(auth.uid);

    return ref.snapshots();
  }

  ///Check if current user has liked the left part of a shout
  ///Returns a stream, such that didLike = snapshot.data.exists
  Stream<DocumentSnapshot> myShoutLeftLikeStream(Post post) {
    final ref =
        postRef(post.id).collection('shout_left_likes').document(auth.uid);

    return ref.snapshots();
  }

  ///Check if current user has liked the right part of a shout
  ///Returns a stream, such that didLike = snapshot.data.exists
  Stream<DocumentSnapshot> myShoutRightLikeStream(Post post) {
    final ref =
        postRef(post.id).collection('shout_right_likes').document(auth.uid);

    return ref.snapshots();
  }

  DocumentReference _fcmTokensRef({String uid, String token}) =>
      userRef(uid).collection('fcm_tokens').document('tokens');

  Future<void> createFCMDeviceToken({String uid, String token}) {
    final ref = _fcmTokensRef(uid: uid, token: token);
    return ref.setData(
      {
        'tokens': FieldValue.arrayUnion([token])
      },
      merge: true,
    );
  }

  Future<void> deleteFCMToken({String uid, String token}) {
    final ref = _fcmTokensRef(uid: uid, token: token);
    return ref.setData(
      {
        'tokens': FieldValue.arrayRemove([token])
      },
      merge: true,
    );
  }
}
