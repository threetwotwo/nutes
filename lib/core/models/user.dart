import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:nutes/utils/image_file_bundle.dart';

class PrivateInfo {
  final String email;

  PrivateInfo(this.email);
}

class UserProfile {
  final String uid;
  final User user;
  final UserStats stats;
  final String bio;
//  final bool isPrivate;
  final bool isVerified;
//  final String email;

  UserProfile({
    @required this.uid,
    @required this.user,
    @required this.stats,
    @required this.bio,
//    @required this.isPrivate,
    @required this.isVerified,
//    @required this.email,
  });

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final user = User(
      isPrivate: doc['is_private'] ?? false,
      uid: doc.documentID,
      username: doc['username'] ?? '',
      displayName: doc['display_name'] ?? '',
//      photoUrl: doc['photo_url'] ?? '',
      urls: ImageUrlBundle(
          original: doc['photo_url'] ?? '',
          medium: doc['photo_url_medium'] ?? '',
          small: doc['photo_url_small'] ?? ''),
    );

    final stats = UserStats(
      postCount: doc['post_count'] ?? 0,
      followerCount: doc['follower_count'] ?? 0,
      followingCount: doc['following_count'] ?? 0,
    );

    return UserProfile(
      uid: doc.documentID,
      user: user,
      stats: stats,
      bio: doc['bio'] ?? '',
//      isPrivate: doc['is_private'] ?? false,
      isVerified: doc['is_verified'] ?? false,
    );
  }

  UserProfile copyWith({
    String username,
    String displayName,
    String email,
    ImageUrlBundle bundle,
    String bio,
    UserStats stats,
    bool isPrivate,
    bool isVerified,
    int postCount,
    int followerCount,
    int followingCount,
    bool hasRequestedFollow,
  }) {
    return UserProfile(
      uid: this.uid,
      user: this.user.copyWith(
            username: username,
            displayName: displayName,
//            photoUrl: photoUrl,
            urls: bundle,
            isPrivate: isPrivate,
            hasRequestedFollow: hasRequestedFollow,
          ),
//      isPrivate: isPrivate ?? false,
      isVerified: isVerified ?? false,
      bio: bio ?? this.bio,
      stats: this.stats.copyWith(
                postCount: postCount ?? this.stats.postCount,
                followerCount: followerCount ?? this.stats.followerCount,
                followingCount: followingCount ?? this.stats.followingCount,
              ) ??
          this.stats,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'user': user.toMap(),
      'username': user.username,
      'display_name': user.displayName,
      'photo_url': user.urls.small,
      'bio': bio,
      'is_verified': isVerified,
//      'is_private': isPrivate,
      'post_count': stats.postCount,
      'follower_count': stats.followerCount,
      'following_count': stats.followingCount,
    };
  }
}

///For when there is no need to display any other data
///other than user's username and photo
class User {
  final String uid;
  final String username;
  final String displayName;
//  final String photoUrl;
  final ImageUrlBundle urls;
  final bool isPrivate;
  final bool hasRequestedFollow;

  User({
    @required this.uid,
    @required this.username,
    @required this.displayName,
//    @required this.photoUrl,
    @required this.isPrivate,
    @required this.urls,
    this.hasRequestedFollow,
  });

  factory User.empty() {
    return User(
        uid: '',
        username: '',
        displayName: '',
        urls: ImageUrlBundle.empty(),
        isPrivate: false);
  }

  factory User.fromDoc(DocumentSnapshot doc) {
    final data = doc.data;
    if (data == null || doc.documentID == 'list') return null;

    final urlBundle = ImageUrlBundle.fromUserDoc(doc);

//    final urlBundles = urlBundle
//        .map((e) => ImageUrlBundle.fromMap(urlBundle.indexOf(e), e))
//        .toList();
    return User(
      isPrivate: data['is_private'] ?? false,
      uid: doc.documentID,
      username: data['username'] ?? '',
      displayName: data['display_name'] ?? '',
      urls: urlBundle,
    );
  }

  factory User.fromMap(Map map, {String uid}) {
    return User(
      isPrivate: map['is_private'] ?? false,
      uid: uid ?? map['uid'] ?? '',
      username: map['username'] ?? '',
      displayName: map['display_name'] ?? '',
      urls: ImageUrlBundle(
        original: map['photo_url'] ?? '',
        medium: map['photo_url_medium'] ?? '',
        small: map['photo_url_small'] ?? '',
      ),
//      photoUrl: map['photo_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_private': isPrivate,
      'uid': uid,
      'username': username,
      'display_name': displayName,
      'photo_url': urls.original,
      'photo_url_medium': urls.medium,
      'photo_url_small': urls.small,
//      'photo_url': photoUrl,
    };
  }

  User copyWith({
    String username,
    String displayName,
    String email,
//    String photoUrl,
    ImageUrlBundle urls,
    bool isPrivate,
    hasRequestedFollow,
  }) {
    return User(
      isPrivate: isPrivate ?? this.isPrivate,
      uid: this.uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
//      photoUrl: photoUrl ?? this.photoUrl,
      urls: urls ?? this.urls,
      hasRequestedFollow: hasRequestedFollow ?? this.hasRequestedFollow,
    );
  }
}

class UserStats {
  final int postCount;
  final int followerCount;
  final int followingCount;

  UserStats({
    @required this.postCount,
    @required this.followerCount,
    @required this.followingCount,
  });

  factory UserStats.empty() {
    return UserStats(postCount: 0, followerCount: 0, followingCount: 0);
  }

  factory UserStats.fromDoc(DocumentSnapshot doc) {
    if (doc.data == null) {
      return UserStats(postCount: 0, followerCount: 0, followingCount: 0);
    }
    final data = doc.data;
    return UserStats(
      postCount: data['post_count'] ?? 0,
      followerCount: data['follower_count'] ?? 0,
      followingCount: data['following_count'] ?? 0,
    );
  }

  factory UserStats.fromSnap(DataSnapshot snap) {
    if (snap.value == null) {
      return UserStats(postCount: 0, followerCount: 0, followingCount: 0);
    }
    final data = snap.value;
    return UserStats(
      postCount: data['post_count'] ?? 0,
      followerCount: data['follower_count'] ?? 0,
      followingCount: data['following_count'] ?? 0,
    );
  }

  UserStats copyWith({int postCount, int followerCount, int followingCount}) {
    return UserStats(
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  UserStats incrementFollowerCount() {
    return this.copyWith(followerCount: this.followerCount + 1);
  }

  UserStats decrementFollowerCount() {
    return this.copyWith(followerCount: this.followerCount - 1);
  }
}
