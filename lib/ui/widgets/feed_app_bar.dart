import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/logos.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onCreatePressed;
  final Function onLogoutPressed;
  final Function onDM;

  const FeedAppBar({
    Key key,
    this.onCreatePressed,
    this.onLogoutPressed,
    this.onDM,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(MdiIcons.pencilPlus),
        onPressed: onCreatePressed,
        color: Colors.black,
      ),
      title: NutesLogoPlain(),
      actions: <Widget>[
//        IconButton(
//          icon: Icon(SimpleLineIcons.logout),
//          onPressed: onLogoutPressed,
//          color: Colors.black,
//        ),
        StreamBuilder<QuerySnapshot>(
            stream: Repo.DMStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              int unreadCount = 0;
              final docs = snapshot.data.documents;

              docs.removeWhere((doc) =>
                  (doc.data ?? {})['last_checked']['sender_id'] ==
                  FirestoreService.ath.uid);

              final count = docs.where((doc) {
                final data = doc.data ?? {};

                final Timestamp lastSeen = data['last_seen_timestamp'];
                final Timestamp lastChecked = data['last_checked_timestamp'];

                return lastSeen == null ||
                    (lastChecked.seconds > lastSeen.seconds);
              }).length;

              unreadCount = count;

              return Stack(
                children: <Widget>[
                  Center(
                    child: IconButton(
                      icon: Icon(
                        SimpleLineIcons.paper_plane,
                      ),
                      onPressed: onDM,
                      color: Colors.black,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned.fill(
                      top: 13,
                      right: 8,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blueAccent[400],
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                ],
              );
            }),
      ],
      elevation: 1.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
