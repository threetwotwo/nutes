import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/chat_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/timeAgo.dart';

class DMListItem extends StatefulWidget {
//  final DocumentSnapshot doc;
  final User user;
  final Map lastChecked;
  final Timestamp endAt;
  final Timestamp lastSeenTimestamp;
  final Timestamp lastSeenTimestampPeer;

  final bool hasUnreadMessages;

  const DMListItem({
    Key key,
    this.user,
    this.lastChecked,
    this.endAt,
    this.lastSeenTimestamp,
    this.lastSeenTimestampPeer,
    this.hasUnreadMessages = false,
  }) : super(key: key);

  @override
  _DMListItemState createState() => _DMListItemState();
}

class _DMListItemState extends State<DMListItem> {
  final auth = Auth.instance;

  @override
  Widget build(BuildContext context) {
    final lastChecked = widget.lastChecked;
    final lastCheckedTimestamp = lastChecked['timestamp'];

    return GestureDetector(
      onHorizontalDragUpdate: (details) => print(details),
      onTap: () => widget.user == null
          ? {}
          : Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(
                peer: widget.user,
                lastSeenTimestamp: widget.lastSeenTimestamp,
                lastSeenTimestampPeer: widget.lastSeenTimestampPeer,
              ),
            )),
      child: Slidable(
        key: UniqueKey(),
        actionPane: SlidableBehindActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => showCupertinoDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text("Delete Conversation?"),
                content: Text("\n Deleting removes the conversation from your "
                    "inbox, but no one else's inbox."),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoDialogAction(
                    child: Text("Delete"),
                    isDestructiveAction: true,
                    onPressed: () {
                      Repo.deleteChatWithUser(widget.user);
                      return Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
        child: AvatarListItem(
          avatar: AvatarImage(
            url: widget.user.urls.small,
            spacing: 0,
          ),
          title: widget.user.username,
          subtitleStyle: !widget.hasUnreadMessages ? null : TextStyles.w600Text,
          subtitle: (lastChecked['type'] == 1
                  ? lastChecked['sender_id'] == auth.profile.uid
                      ? 'You sent a message'
                      : 'Sent you a message'
                  : lastChecked['content'] ?? '') +
              ' · ' +
              TimeAgo.formatShort(lastCheckedTimestamp.toDate()),
          trailingFlexFactor: 1,
          trailingWidget: !widget.hasUnreadMessages
              ? null
              : Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent[400],
                      borderRadius: BorderRadius.circular(10)),
                ),
        ),
      ),
    );
  }
}
