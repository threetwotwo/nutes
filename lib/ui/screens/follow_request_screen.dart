import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowRequestScreen extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  final auth = FirestoreService.ath;

  FollowRequestScreen({Key key, this.stream}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: Text(
          'Follow Requests',
          style: TextStyles.w600Text,
        ),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('users')
                  .document(auth.uid)
                  .collection('follow_requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey)));
                } else {
                  final docs = snapshot.data.documents;
                  return docs.isEmpty
                      ? ListTile(
                          title: Text('No Follow '
                              'Requests'),
                        )
                      : ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final user = User.fromMap(doc['user'] ?? {});

                            return AvatarListItem(
                              trailingFlexFactor: 6,
                              avatar: AvatarImage(
                                url: user.urls.small,
                                spacing: 0,
                                padding: 12,
                              ),
                              title: user.username,
                              subtitle: user.displayName,
                              trailingWidget: FollowRequestActionButtons(
                                user: user,
                                onConfirm: (user) =>
                                    Repo.authorizeFollowRequest(user),
                                onDelete: (uid) =>
                                    Repo.redactFollowRequest(auth.uid, uid),
                              ),
                            );
                          },
                        );
                }
              }),
//          child: ListView.builder(
//            itemCount: 3,
//            itemBuilder: (context, index) => AvatarListItem(
//              trailingFlexFactor: 5,
//              avatar: AvatarImage(
//                url: '',
//                spacing: 0,
//              ),
//              title: 'username',
//              subtitle: 'display name',
//              trailingWidget: FollowRequestActionButtons(),
//            ),
//          ),
        ),
      ),
    );
  }
}

class FollowRequestActionButtons extends StatelessWidget {
  final Function(User) onConfirm;
  final Function(String) onDelete;
  final User user;

  const FollowRequestActionButtons({
    Key key,
    this.onConfirm,
    this.onDelete,
    this.user,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: FlatButton(
            onPressed: () => onConfirm(this.user),
            color: Colors.blueAccent,
            child: Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: OutlineButton(
            onPressed: () => onDelete(this.user.uid),
            child: Text('Delete'),
          ),
        ),
      ],
    );
  }
}
