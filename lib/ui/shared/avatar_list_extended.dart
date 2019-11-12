import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'avatar_list_item.dart';
import 'avatar_image.dart';

class AvatarListExtended extends StatefulWidget {
  final List<User> users;

  const AvatarListExtended({Key key, this.users}) : super(key: key);

  @override
  _AvatarListExtendedState createState() => _AvatarListExtendedState();
}

class _AvatarListExtendedState extends State<AvatarListExtended> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: Repo.myFollowingListStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          final List followingIds = snapshot.data.data == null
              ? []
              : snapshot.data.data['uids'] ?? [];
          return ListView.builder(
              shrinkWrap: true,
              itemCount: widget.users.length,
              itemBuilder: (context, index) {
                final user = widget.users[index];
                final isFollowing = followingIds.contains(user.uid);
                final isMe = user.uid == Repo.currentProfile.uid;

                return AvatarListItem(
                  avatar: AvatarImage(
                    url: user.photoUrl,
                  ),
                  title: user.username,
                  subtitle: user.displayName,
                  onAvatarTapped: () =>
                      Navigator.push(context, ProfileScreen.route(user.uid)),
                  onBodyTapped: () =>
                      Navigator.push(context, ProfileScreen.route(user.uid)),
                  trailingWidget: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isMe
                        ? SizedBox()
                        : FollowButtonExtended(
                            isRequested: user.hasRequestedFollow == true,
                            isFollowing: isFollowing,
                            onRequest: () {
                              setState(() {
                                widget.users[index] =
                                    user.copyWith(hasRequestedFollow: false);
                              });
                            },
                            onFollow: () {
                              if (isFollowing) {
                                Repo.unfollowUser(user.uid);
                              } else {
                                Repo.requestFollow(user, user.isPrivate);
                                if (user.isPrivate) {
                                  setState(() {
                                    widget.users[index] =
                                        user.copyWith(hasRequestedFollow: true);
                                  });
                                }
                              }
                            },
                          ),
                  ),
                );
              });
        });
  }
}
