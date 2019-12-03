import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:nutes/core/models/activity.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/comment.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/post_type.dart';
import 'package:nutes/core/models/story.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';

///The service that handles all reads and writes to firestore
class FirestoreService {
  static final Firestore shared = Firestore.instance;

  final auth = Auth.instance;
  final cache = LocalCache.instance;

  static User currentUser;
  List<String> _followings = [];

  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler) async {
    return shared.runTransaction(transactionHandler);
  }

  WriteBatch batch() {
    return shared.batch();
  }

  ///For shouts
  DocumentReference publicPostRef() {
    return shared.collection('posts').document();
  }

  DocumentReference get myProfileRef => userRef(Repo.currentProfile.uid);

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
    return activityRef(Repo.currentProfile.uid);
  }

  DocumentReference userPostRef(String uid, String docId) {
    return shared
        .collection('users')
        .document(uid)
        .collection('posts')
        .document(docId);
  }

  DocumentReference _chatRef(String chatId) {
    return shared.collection('chats').document(chatId);
  }

  DocumentReference _myChatRefWithUser(String uid) {
    return userRef(Repo.currentProfile.uid).collection('chats').document(uid);
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
    return userRef(auth.profile.uid)
        .collection('snapshots')
        .document('stories');
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

  Future<UserProfile> getUserProfile(String uid) async {
    final doc = await userRef(uid).get();
    return !doc.exists ? null : UserProfile.fromDoc(doc);
  }

  ///Returns user object from user doc
  Future<User> getUser(String uid) async {
    final doc = await userRef(uid).get();
    return User.fromDoc(doc);
  }

  Future<List<User>> searchUsers(String text) async {
    if (text == null) return [];
    if (text.isEmpty) return [];

    final length = text.length - 1;
    final char = text[length];

    final end = text.replaceRange(
        length, length + 1, String.fromCharCode(char.codeUnitAt(0) + 1));

    print('start: $text, end: $end');

    final query = shared
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: text)
        .where('username', isLessThan: end)
        .limit(5);

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
    final ref = shared.collection('users').document(Repo.currentProfile.uid);

    return ref.updateData({'is_private': isPrivate});
  }

  ///Updates the [end_at] field for the chat doc ref
  Future deleteChatWithUser(User user) async {
    final selfId = Repo.currentProfile.uid;

    final selfRef = userRef(selfId).collection('chats').document(user.uid);

    print(selfRef.path);

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
    return _chatRef(chatId).collection('messages').snapshots();
  }

  Stream<QuerySnapshot> messageStream(
      String chatId, Timestamp endAt, int limit) {
    final ref = _chatRef(chatId);

    return ref
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .endAt([endAt])
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> messageStreamPaginated(
      String chatId, Timestamp endAt, DocumentSnapshot startAfter) {
    final ref = _chatRef(chatId);

    return ref
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .endAt([endAt])
        .startAfterDocument(startAfter)
        .limit(2)
        .snapshots();
  }

  Stream<QuerySnapshot> DMStream() {
//    final timestamp = Timestamp.now();

//    final todayInSeconds = timestamp.seconds;
//    final todayInNanoSeconds = timestamp.nanoseconds;

    ///24 hours ago since now
//    final cutOff = Timestamp(todayInSeconds - 2628000000, todayInNanoSeconds);

    return userRef(Repo.currentProfile.uid)
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
        .where('persist_${Repo.currentProfile.uid}', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  ///Retrieves uids of people that current user is chatting with
  ///Returns nothing if there are no messages in the chat document
  Stream<List<String>> getChatRecipientIds() {
    final qsStream = shared
        .collection('chats')
        .where('participants', arrayContains: Repo.currentProfile.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();

    final x = qsStream.map((qs) => qs.documents.map((ds) {
          return (ds.data['participants'] as List<String>)
              .firstWhere((p) => p != Repo.currentProfile.uid);
        }));

    return x;
  }

  ///Where should i put this? Do I even need this?
  ///Dont do anything if there are no messages
  Future resolveParticipants(
      String chatId, Timestamp timestamp, User recipient) async {
    final senderId = Repo.currentProfile.uid;
    final recipientId = recipient.uid;

    Map senderMap = {'timestamp': timestamp};
    senderMap.addAll(Repo.currentProfile.toMap());

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
      'persist_${Repo.currentProfile.uid}': true,
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

    final selfRef =
        userRef(Repo.currentProfile.uid).collection('chats').document(peer.uid);

    final peerRef =
        userRef(peer.uid).collection('chats').document(Repo.currentProfile.uid);

    final selfMap = Repo.currentProfile.toMap();

    ///Auto updates the peer info
    final peerMap = peer.toMap();

    final payload = {
      'sender_id': Repo.currentProfile.uid,
      'timestamp': timestamp,
      'content': response,
      'type': BubbleHelper.stringValue(Bubbles.shout_complete),
      'metadata': {'responding_to': content},
    };

    return shared.runTransaction((t) {
      t.set(selfRef, {
        'is_persisted': true,
        'last_checked': payload,
        'last_checked_timestamp': timestamp,
        'user': peerMap,
      });
      t.set(peerRef, {
        'is_persisted': true,
        'last_checked': payload,
        'last_checked_timestamp': timestamp,
        'user': selfMap,
      });
      return t.set(messageRef, payload);
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
  Future<void> uploadMessage(
    DocumentReference messageRef,
    Bubbles type,
    String content,
    User peer,
  ) async {
    final timestamp = Timestamp.now();

    final selfRef =
        userRef(Repo.currentProfile.uid).collection('chats').document(peer.uid);

    final peerRef =
        userRef(peer.uid).collection('chats').document(Repo.currentProfile.uid);

    final selfMap = Repo.currentProfile.toMap();

    ///Auto updates the peer info
    final peerMap = peer.toMap();

    final payload = {
      'sender_id': Repo.currentProfile.uid,
      'timestamp': timestamp,
      'content': content,
      'type': BubbleHelper.stringValue(type),
    };

    return shared.runTransaction((t) {
      t.set(selfRef, {
        'is_persisted': true,
        'last_checked': payload,
        'last_checked_timestamp': timestamp,
        'user': peerMap,
      });
      t.set(peerRef, {
        'is_persisted': true,
        'last_checked': payload,
        'last_checked_timestamp': timestamp,
        'user': selfMap,
      });
      return t.set(messageRef, payload);
    });
  }

  ///Create a new message
  Future<void> createMessage(
      {@required String chatId,
      @required User recipient,
      @required String content,
      int type = 0}) async {
    // type: 0 = text, 1 = image, 2 = sticker
    final docRef = _messagesRef(chatId).document();

    final timestamp = Timestamp.now();

    final data = {
      'sender_id': Repo.currentProfile.uid,
      'timestamp': timestamp,
      'content': content,
      'type': type
    };

    return Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        docRef,
        data,
      );

      ///if chat does not exists, initialize its participants
      await resolveParticipants(chatId, timestamp, recipient);
      updateChatLastChecked(chatId, data);
    });
  }

  void updateProfile({
    String username,
    String displayName,
    String bio,
    String photoUrl,
  }) {
    shared.collection('users').document(Repo.currentProfile.uid).updateData({
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (photoUrl != null) 'photo_url': photoUrl,
    });
  }

  updatePhotoUrl({@required String uid, @required String url}) {
    shared.collection('users').document(uid).updateData({'photo_url': url});
  }

  Future getMyFollowRequests() {}

  ///Writes a follow request doc on a given user's follow request collection
  Future requestFollow(String uid) {
    final batch = shared.batch();
    final ref = _followRequestsRef(uid).document(Repo.currentProfile.uid);
    final ref2 = myFollowRequestsRef();

    batch.setData(
      ref,
      {
        'user': Repo.currentProfile.toMap(),
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
      {@required String followerId, @required User following}) async {
    final followerRef = shared.collection('users').document(followerId);
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
        followingRef.collection('followers').document(followerId);

    batch.setData(
      followingFollowerRef,
      {
        'follower_id': followerId,
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
    return addRecentPostsToFollowerFeed(followerId, following.uid);
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
    final followerRef =
        shared.collection('users').document(Repo.currentProfile.uid);

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
        followedRef.collection('followers').document(Repo.currentProfile.uid);

    batch.delete(followingFollowerRef);

    ///4. (Cloud function) decrement following's follower count
    ///5. (Cloud function) decrement follower's following count
    ///
    ///6. (Cloud function) delete following's recent posts from follower's feed
    ///
    batch.commit();

    ///2a. Delete recent posts from follower feed
    return deleteRecentPostsToFollowerFeed(Repo.currentProfile.uid, uid);
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
        .document(auth.profile.uid)
        .collection('followings_list')
        .document('list');
  }

  Stream<DocumentSnapshot> myFollowingListStream() {
    return myFollowingListRef().snapshots();
  }

  Future updateFollowingsArray(List<User> users) async {
    final ref = shared.collection('users').document(Repo.currentProfile.uid);

    final doc = await ref.get();

    final Map followings = doc['followings'] ?? {};

    users.forEach((user) => followings[user.uid] = {
          'username': user.username,
          'photo_url': user.photoUrl,
        });

    return ref.updateData({'followings': followings});
  }

  ///Abridged user contains the minimum info to display a user avatar
  ///contains username and photo_url
  Future<List<User>> getAbridgedUserFromUids(List<String> uids) async {
    ///get followings array
    final ref = shared.collection('users').document(auth.profile.uid);

    final doc = await ref.get();

    final Map followings = doc['followings'] ?? {};

    List<User> users = [];

    List<String> missingUids = [];

    List<Future<User>> futureUsers = [];

    uids.forEach((uid) {
      User user;

      if (followings[uid] == null) {
        ///Get uids that are not in the followings array
        missingUids.add(uid);
      } else {
        final Map userMap = followings[uid] ?? {};
        user = User(
          uid: uid,
          username: userMap['username'] ?? '',
          photoUrl: userMap['photo_url'] ?? '',
          displayName: userMap['display_name'] ?? '',
          isPrivate: userMap['is_private'] ?? false,
        );
        users.add(user);
      }
    });

    ///get user info for each missing uid
    if (missingUids.isNotEmpty) {
      missingUids.forEach((uid) {
//        final futureUser = getUser(uid);
//        futureUsers.add(futureUser);
      });

      final missingUsers = await Future.wait(futureUsers);

      users.addAll(missingUsers);

      ///Update all missing followings
      await updateFollowingsArray(missingUsers);
    }

    return users;
  }

  updateStorySnapshot(String uid, Timestamp timestamp) async {
    Timestamp timestamp;

    ///get latest story timestamp
    final followingRef =
        _storiesRef(uid).orderBy('timestamp', descending: true).limit(1);

    final docs = await followingRef.getDocuments();

    if (docs.documents.isEmpty)
      timestamp = Timestamp.fromDate(DateTime(2011));
    else
      timestamp = Moment.fromDoc(docs.documents.first).timestamp;

    final ref = _mySnapshotStoriesRef();
    final payload = {
      uid: {'timestamp': timestamp},
    };
    ref.setData({'followings': payload}, merge: true);
  }

  Future<List<UserStory>> getSnapshotStories(
      {List<UserStory> userStories}) async {
    final ref = _mySnapshotStoriesRef();

    final doc = await ref.get();

    return await UserStory.fromDoc(doc, userStories: userStories);
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
    final story = Story(startAt: 0, lastLoaded: 0, moments: moments);
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
      owner: auth.profile.user,
      parentId: parentComment?.id ?? null,
      parentOwner: parentComment?.owner ?? null,
    );
  }

  Future<List<Comment>> getComments(String postId) async {
    final commentsRef = shared
        .collection('posts')
        .document(postId)
        .collection('comments')
        .orderBy('like_count', descending: true)
        .limit(30);

    final docs = await commentsRef.getDocuments();

    print('comments: ${docs.documents.length} for post $postId');

    return docs.documents.map((doc) => Comment.fromDoc(doc)).toList();
  }

  Future uploadComment({
    @required Post post,
    @required Comment comment,

//                         @required User owner,
//    @required String text,
//    String parentId,
  }) async {
    final postRef = shared.collection('posts').document(post.id);
    final commentRef = postRef.collection('comments').document();

//    final timestamp = Timestamp.now();

    final batch = shared.batch();

    final commentPayload = {
      'parent_id': comment.parentId,
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
    });
  }

  DocumentReference createStoryRef() {
    final ref = shared
        .collection('users')
        .document(Repo.currentProfile.uid)
        .collection('stories')
        .document();
    return ref;
  }

  DocumentReference myPostRef(String id) {
    final ref = shared
        .collection('users')
        .document(Repo.currentProfile.uid)
        .collection('posts')
        .document(id);
    return ref;
  }

  DocumentReference createUserPostRef() {
    final ref = shared
        .collection('users')
        .document(Repo.currentProfile.uid)
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

  ///Checks if current user has liked a post
  Future<PostMyLikes> getMyLikesForPost(String postId) async {
    final myLikeRef = myProfileRef.collection('my_post_likes').document(postId);

    final doc = await myLikeRef.get();

    final List data =
        !doc.exists ? [] : doc.data == null ? [] : doc.data['likes'] ?? [];

    return PostMyLikes.fromList(data);
  }

  Future likeShoutBubble({@required isChallenger, @required Post post}) async {
    final collectionName = isChallenger
        ? 'challenger_likes'
        : 'challenged_li'
            'kes';

    final ref = shared
        .collection('posts')
        .document(post.id)
        .collection(collectionName)
        .document(Repo.currentProfile.uid);

    final key = isChallenger ? 'challenger_likes' : 'challenged_likes';

    final timestamp = Timestamp.now();

//    final handler = await engagementHandler(key, post, timestamp, false);

    return shared.runTransaction((t) {
//      handler.docExists
//          ? t.update(engagementRef(), handler.payload)
//          : t.set(engagementRef(), handler.payload);
      return t.set(ref, {'timestamp': timestamp});
    });
  }

  Future unlikeShoutBubble(
      {@required isChallenger, @required Post post}) async {
    final data = post.metadata;

    final String uid =
        isChallenger ? data['challenger']['uid'] : data['challenged']['uid'];

    if (uid.isEmpty || uid == null) return null;

    final collectionName = isChallenger
        ? 'challenger_likes'
        : 'challenged_li'
            'kes';

    final ref = shared
        .collection('posts')
        .document(post.id)
        .collection(collectionName)
        .document(Repo.currentProfile.uid);

    final key = isChallenger ? 'challenger_likes' : 'challenged_likes';

    final timestamp = Timestamp.now();

//    final handler = await engagementHandler(key, post, timestamp, true);

    return shared.runTransaction((t) {
//      handler.docExists
//          ? t.update(engagementRef(), handler.payload)
//          : t.set(engagementRef(), handler.payload);
      return t.delete(ref);
    });
  }

  Future likeChallenger(bool like, Post post) async {
    final data = post.metadata;

    final String challengerId = data['challenger']['uid'];
    final String challengedId = data['challenged']['uid'];

    final uid = Repo.currentProfile.uid;

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
    final likeDocRef =
        postRef.collection('likes').document(Repo.currentProfile.uid);

    batch.setData(likeDocRef, {
      'timestamp': timestamp,
      'owner_id': Repo.currentProfile.uid,
      'post_type': PostHelper.stringValue(post.type),
      'post_id': post.id,
      if (post.metadata != null) 'post_metadata': post.metadata,
      if (post.urls.isNotEmpty) 'post_url': post.urls.first.small,
    });

    ///Due to potential scalability issues ,
    ///might need to write this to my_likes col ref instead
    ///that way, you can easily query for your like plus your following likes
    /// for the post
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
    final myPostLikesColRef =
        myProfileRef.collection('my_post_likes').document(post.id);

    batch.setData(
        myPostLikesColRef,
        {
          'likes': FieldValue.arrayUnion(['post'])
        },
        merge: true);
//    final myLikesDocRef =
//        myProfileRef.collection('activity').document('post_likes');
//
//    batch.setData(
//        myLikesDocRef,
//        {
//          'likes': FieldValue.arrayUnion([post.id])
//        },
//        merge: true);

    ///3. (Cloud function) update post like count
    ///4. (Cloud function) write to my followers' followings' likes feed

//    postRef.setData({'like_count': FieldValue.increment(1)}, merge: true);

    return batch.commit();
  }

  Future unlikePost(Post post) async {
    final postRef = shared.collection('posts').document(post.id);

    final likesRef =
        postRef.collection('likes').document(Repo.currentProfile.uid);

    final batch = shared.batch();

//    postRef.setData({'like_count': FieldValue.increment(-1)}, merge: true);

    final myPostLikesColRef =
        myProfileRef.collection('my_post_likes').document(post.id);

    batch.setData(
        myPostLikesColRef,
        {
          'likes': FieldValue.arrayRemove(['post'])
        },
        merge: true);

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

    batch.delete(likesRef);

    return batch.commit();
  }

  ///TODO: how to get didlikes and stats?
  Stream<QuerySnapshot> myPostStream() {
    final ref = userRef(auth.profile.uid)
        .collection('posts')
        .orderBy('timestamp', descending: true);
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

  Future<List<Post>> getPostsForUser(
      {String uid, int limit = 10, DocumentSnapshot startAfter}) async {
    List<Post> posts = [];

    final query = startAfter == null
        ? _userPostsRef(uid)
            .limit(limit)
            .orderBy('timestamp', descending: true)
            .getDocuments()
        : _userPostsRef(uid)
            .startAfter([startAfter])
            .limit(limit)
            .orderBy('timestamp', descending: true)
            .getDocuments();

    final qs = await query;

    final docs = qs.documents;

    posts.addAll(docs.map((doc) => Post.fromDoc(doc)).toList());

    ///Remove bad posts
    posts.removeWhere((post) => post == null);

    final result = await getPostsComplete(posts);

    return result;
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
    print(stats.map((s) => s.ownerId).toList());

    final result = await getPostsFromStats(stats);

    print(result.map((p) => p.id).toList());
//    result.removeWhere((p) => p == null);
    return docs.documents.isNotEmpty
        ? PostCursor(result, docs.documents.last)
        : PostCursor(result, startAfter);
  }

  Future<PostCursor> getTrendingPosts(DocumentSnapshot startAfter) async {
    final statsColRef = startAfter == null
        ? shared
            .collection('posts')
            .orderBy('like_count', descending: true)
            .limit(10)
        : shared
            .collection('posts')
            .orderBy('like_count', descending: true)
            .startAfterDocument(startAfter)
            .limit(10);

    final docs = await statsColRef.getDocuments();

    final stats = docs.documents.map((doc) => PostStats.fromDoc(doc)).toList();

    stats.removeWhere((s) => s.ownerId == null || s.ownerId.isEmpty);
    print(stats.map((s) => s.ownerId).toList());

    final result = await getPostsFromStats(stats);

    print(result.map((p) => p.id).toList());
//    result.removeWhere((p) => p == null);

    return docs.documents.isNotEmpty
        ? PostCursor(result, docs.documents.last)
        : PostCursor(result, startAfter);
  }

  Future<List<Post>> getFeed() async {
    final ref = userRef(auth.profile.uid)
        .collection('feed')
        .orderBy('timestamp', descending: true);
    final docs = await ref.getDocuments();

    ///Required reads:
    /// Note: a query is counted as 1 read if no doc is returned(see Firestore
    /// Pricing)
    ///
    ///1. post body from user feed doc ref;
    ///2. post stats from public ref
    ///2. user did like
    ///3. followings did like (up to 3)
    ///4. if shout, left and right my + following (up to 3) did likes
    ///
    /// min reads = 4 (text) 6 (shout), max = 7 (text), 12(shout)
    List<Post> posts = docs.documents.map((doc) => Post.fromDoc(doc)).toList();

    List<Post> result2 = await getPostsComplete(posts);

    return result2;
  }

  Future<List<Activity>> getFollowingsActivity(List<User> followings) async {
    final query = myFollowingsActivityColRef
        .where('type', isEqualTo: 'post_like')
        .orderBy('timestamp', descending: true)
        .limit(30);

    final docs = await query.getDocuments();

    return docs.documents
        .map((doc) => Activity.fromDoc(doc, followings))
        .toList();
  }

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

  Future<List<User>> getMyUserFollowings(String uid) async {
    final docs = await userRef(uid)
        .collection('followings_list')
        .where('type', isEqualTo: 'users')
        .getDocuments();

    final s = [];
    docs.documents.forEach((doc) =>
        (doc.data['users'] as Map).values.forEach((map) => s.add(map)));
//        .map((m) => m.values);
    print(s);

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
      print(doc.data);
      return doc.data['owner_id'] ?? '';
    }).toList();

    final users = uids
        .map((uid) => userFollowings.firstWhere((user) => user.uid == uid,
            orElse: () => null))
        .toList();

    users.removeWhere((user) => user == null);
    return users;
  }

  Future<List<Post>> getPostsFromStats(List<PostStats> stats) async {
    final futures = stats.map((st) async {
      final result = await getPost(st.postId, st.ownerId);

      final post = result.copyWith(stats: st);

      return post;
    }).toList();

    return Future.wait(futures);
  }

  Future<Post> getPostComplete(String postId, String ownerId) async {
    final userFollowings = await getMyUserFollowings(Repo.currentProfile.uid);

    final post = await getPost(postId, ownerId);

    return post.copyWith(
      topComments: await getPostTopComments(post.id),
      stats: await getPostStats(post.id),
      myLikes: await getMyLikesForPost(post.id),
      myFollowingLikes: await getFollowingLikesOfPost(post.id, userFollowings),
    );
  }

  Future<Post> getPostStatsAndLikes(Post post) async {
    final userFollowings = await getMyUserFollowings(Repo.currentProfile.uid);

    return post.copyWith(
      stats: await getPostStats(post.id),
      myLikes: await getMyLikesForPost(post.id),
      myFollowingLikes: await getFollowingLikesOfPost(post.id, userFollowings),
    );
  }

  Future<List<Post>> getPostsComplete(List<Post> posts) async {
    final userFollowings = await getMyUserFollowings(auth.profile.uid);
    print('my userFollowings = $userFollowings');

    ///remove null posts
    posts.removeWhere((p) => p == null);

    final futures = posts.map((p) async {
      return p.copyWith(
        topComments: await getPostTopComments(p.id),
        stats: await getPostStats(p.id),
        myLikes: await getMyLikesForPost(p.id),
        myFollowingLikes: await getFollowingLikesOfPost(p.id, userFollowings),
      );
    }).toList();

    final result = await Future.wait(futures);
    return result;
  }

  ///fetch more posts
  ///paginates using list of document snapshots
//  Future<List<Post>> getMorePosts({int limit}) async {
//    List<Post> posts = [];
//
//    ///mark followings that produce empty posts
//    ///and remove them from followings list
//    List<String> followingsToRemove = [];
//
//    if (_lastFeedSnaps.isEmpty) return posts;
////    print(_lastFeedSnaps.values.map((snap) => snap.documentID).toList());
//
//    if (_followings.isEmpty) {
//      final followingsQS = await shared
//          .collection('userFollowings')
//          .document(Repo.currentProfile.uid)
//          .collection('followings')
//          .orderBy('uid')
//          .getDocuments();
//
//      ///exit if there are no followings
//      if (followingsQS.documents.isEmpty) {
//        return posts;
//      }
//      _followings
//          .addAll(followingsQS.documents.map((s) => s.documentID).toList());
//    }
//
////    _lastFeedFollowing = followingsQS.documents.last;
//    print('getMorePosts followings: $_followings');
//
//    for (final following in _followings) {
//      print('get more posts of $following');
//
//      ///continue if current following has no snap
//      final lastSnap = _lastFeedSnaps[following];
//
//      if (lastSnap == null) continue;
//
//      final postsQS = await shared
//          .collection('posts')
//          .where('uid', isEqualTo: following)
//          .orderBy('timestamp', descending: true)
//          .startAfter([lastSnap['timestamp']])
//          .limit(limit)
//          .getDocuments();
//
//      ///continue to the next following and remove the snap
//      ///if all the posts have been fetched for the current following
//      if (postsQS.documents.isEmpty) {
//        print('empty posts for $following');
//        followingsToRemove.add(following);
//        _lastFeedSnaps.remove(following);
//        continue;
//      }
//
//      ///update snap for the current following
//      _lastFeedSnaps[following] = postsQS.documents.last;
//
//      posts.addAll(postsQS.documents.map((s) => Post.fromDoc(s)).toList());
//    }
//
//    ///remove empty followings
//    _followings.removeWhere((s) => followingsToRemove.contains(s));
//
//    return posts;
//  }

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
          photoUrl: '',
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
    await FirebaseAuth.instance.signOut();
    auth.reset();
  }

  Future<UserProfile> signInWithUsernameAndPassword(
      {String username, String password}) async {
    ///check if username exists
    print('signing in $username');
    final qs = await shared
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .getDocuments();

    if (qs.documents.isEmpty) return null;

    String email;

    ///get email associated with username
    email = qs.documents.first.data['email'];

    if (email == null ?? email.isEmpty) {
      final info = await qs.documents.first.reference
          .collection('private')
          .document('info')
          .get();

      email = info['email'] ?? '';
    }

    ///check if email matches with password entered
    ///

    final authenticatedUser = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((err) {
      print(err);
//      return err;
      throw (err);
    });

//      ///return user object
    if (authenticatedUser != null)
      return UserProfile.fromDoc(qs.documents.first);

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
}
