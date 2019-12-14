import 'package:flutter/material.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowRequestScreen extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  final auth = Auth.instance;

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
                  .document(auth.profile.uid)
                  .collection('follow_requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey)));
                } else {
                  final requests = snapshot.data.documents;
                  return requests.isEmpty
                      ? ListTile(
                          title: Text('No Follow '
                              'Requests'),
                        )
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final data = requests[index].data;
                            final Map user = data['user'] ?? {};

                            return AvatarListItem(
                              trailingFlexFactor: 5,
                              avatar: AvatarImage(
                                url: user['photo_url'],
                                spacing: 0,
                              ),
                              title: user['username'],
                              subtitle: user['display_name'],
                              trailingWidget: FollowRequestActionButtons(
                                uid: requests[index].documentID,
                                onConfirm: (uid) =>
                                    Repo.authorizeFollowRequest(uid),
                                onDelete: (uid) {
                                  print(uid);
                                  return Repo.redactFollowRequest(
                                      auth.profile.uid, uid);
                                },
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
  final Function(String) onConfirm;
  final Function(String) onDelete;
  final String uid;

  const FollowRequestActionButtons(
      {Key key, this.onConfirm, this.onDelete, this.uid})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: FlatButton(
            onPressed: () => onConfirm(this.uid),
            color: Colors.blue,
            child: Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: OutlineButton(
            onPressed: () => onDelete(this.uid),
            child: Text('Delete'),
          ),
        ),
      ],
    );
  }
}
