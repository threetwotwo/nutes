import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/events.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/dm_list_item.dart';
import 'package:flutter/cupertino.dart';

///Shows a list of chats
class DirectScreen extends StatefulWidget {
  final VoidCallback onLeadingPressed;
  final VoidCallback onTrailingPressed;

  DirectScreen(
      {Key key,
      @required this.onLeadingPressed,
      @required this.onTrailingPressed})
      : super(key: key);

  @override
  _DirectScreenState createState() => _DirectScreenState();
}

class _DirectScreenState extends State<DirectScreen> {
  final auth = Repo.auth;

  Stream<QuerySnapshot> _stream = Repo.DMStream();

  Map<String, bool> unreadChats = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        onLeadingPressed: widget.onLeadingPressed,
        onTrailingPressed: widget.onTrailingPressed,
        title: Text(
          auth.user.username,
          style: TextStyles.header,
        ),
//        trailing: Icon(
//          LineIcons.edit,
//          color: Colors.black,
//          size: 28,
//        ),
      ),
      body: SafeArea(
        child: Container(
          child: Center(
            child: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {},
                        child: Text(
                          'Messages',
                          style: TextStyles.w600Text.copyWith(fontSize: 18),
                        )),
                    FlatButton(
                        onPressed: () {},
                        child: Text(
                          '',
                          style: TextStyles.w600Text
                              .copyWith(fontSize: 14, color: Colors.blueAccent),
                        )),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: _stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return LoadingIndicator();
                      } else {
                        final docs = snapshot.data.documents
                          ..sort((a, b) {
                            final Timestamp aTime =
                                a.data['last_checked_timestamp'];
                            final Timestamp bTime =
                                b.data['last_checked_timestamp'];

                            return bTime.millisecondsSinceEpoch
                                .compareTo(aTime.millisecondsSinceEpoch);
                          });

                        return docs.isEmpty
                            ? EmptyIndicator('No conversations to show')
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(10.0),
                                itemBuilder: (context, index) {
                                  final doc = docs[index];

                                  final userMap = doc['user'];
                                  if (userMap == null) return SizedBox();
                                  final Map lastChecked = doc['last_checked'];
                                  final String lastCheckedSender =
                                      lastChecked['sender_id'];

                                  final Timestamp lastCheckedTimestamp =
                                      doc['last_checked_timestamp'];
                                  final Timestamp lastSeenTimestamp =
                                      doc['last_seen_timestamp'];
                                  final Timestamp lastSeenTimestampPeer =
                                      doc['peer_last_seen_timestamp'];

                                  final user = User.fromMap(userMap);

                                  final endAt = doc['end_at'];

                                  final hasUnread = (lastSeenTimestamp == null)
                                      ? lastCheckedSender != auth.uid
                                      : (lastSeenTimestamp.seconds <
                                              lastCheckedTimestamp.seconds &&
                                          lastCheckedSender != auth.uid);

                                  unreadChats[user.uid] = hasUnread;

                                  eventBus
                                      .fire(ChatReadStatusEvent(unreadChats));
                                  print(unreadChats);
                                  return DMListItem(
                                    user: user,
                                    lastChecked: lastChecked,
                                    lastSeenTimestamp: lastSeenTimestamp,
                                    lastSeenTimestampPeer:
                                        lastSeenTimestampPeer,
                                    endAt: endAt,
                                    hasUnreadMessages: hasUnread,
                                  );
                                },
                                itemCount: snapshot.data.documents.length,
                              );
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
