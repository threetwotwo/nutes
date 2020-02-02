import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'avatar_list_item.dart';
import 'avatar_image.dart';

///ListView with AvatarListItem as its children
///each item also has a follow button
class AvatarListExtended extends StatefulWidget {
  final List<User> users;

  const AvatarListExtended({Key key, this.users}) : super(key: key);

  @override
  _AvatarListExtendedState createState() => _AvatarListExtendedState();
}

class _AvatarListExtendedState extends State<AvatarListExtended> {
  final auth = Repo.auth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: Repo.myFollowingListStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          final List followingIds = snapshot.data.data == null
              ? []
              : snapshot.data.data['uids'] ?? [];
          return StreamBuilder<DocumentSnapshot>(
              stream: Repo.myFollowRequestStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();

                final Map<String, dynamic> data = snapshot.data?.data ?? {};

                final List requests = data['requests'] ?? [];

                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.users.length,
                    itemBuilder: (context, index) {
                      final user = widget.users[index];
                      final isFollowing = followingIds.contains(user.uid);
                      final isMe = user.uid == auth.uid;
                      final isRequested = requests.contains(user.uid);

                      return AvatarListItem(
                        avatar: AvatarImage(
                          url: user.urls.small,
                        ),
                        title: user.username,
                        subtitle: user.displayName,
                        onAvatarTapped: () => Navigator.push(
                            context, ProfileScreen.route(user.uid)),
                        onBodyTapped: () => Navigator.push(
                            context, ProfileScreen.route(user.uid)),
                        trailingWidget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isMe
                              ? SizedBox()
                              : FollowButtonExtended(
                                  isRequested: isRequested,
                                  isFollowing: isFollowing,
                                  onRequest: () {
                                    isRequested
                                        ? Repo.deleteFollowRequest(
                                            FirestoreService.ath.uid, user.uid)
                                        : Repo.requestFollow(user);
                                  },
                                  onFollow: () {
                                    if (isFollowing) {
                                      Repo.unfollowUser(user.uid);
                                    } else {
                                      Repo.requestFollow(user);
                                    }
                                  },
                                ),
                        ),
                      );
                    });
              });
        });
  }
}
