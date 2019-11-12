import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/search_bar.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/chat_avatar_item.dart';
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
  Stream<QuerySnapshot> _chatStream;

  @override
  void initState() {
    _chatStream = Repo.DMStream();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        onLeadingPressed: widget.onLeadingPressed,
        onTrailingPressed: widget.onTrailingPressed,
        title: Text(
          Repo.currentProfile.user.username,
          style: TextStyles.W500Text15.copyWith(fontSize: 18),
        ),
        trailing: Icon(
          LineIcons.edit,
          color: Colors.black,
          size: 28,
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Center(
            child: ListView(
//              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchBar(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {},
                        child: Text(
                          'Messages',
                          style: TextStyles.W500Text15.copyWith(fontSize: 18),
                        )),
                    FlatButton(
                        onPressed: () {},
                        child: Text(
                          '5 Requests',
                          style: TextStyles.W500Text15.copyWith(
                              fontSize: 14, color: Colors.blueAccent),
                        )),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: _chatStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: Text('No conversations to show'));
                      } else {
                        final docs = snapshot.data.documents;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(10.0),
                          itemBuilder: (context, index) {
                            final doc = docs[index];

                            final userMap = doc['user'];
                            if (userMap == null) return SizedBox();
                            final lastChecked = doc['last_checked'];
                            final user = User.fromMap(doc['user']);
                            final endAt = doc['end_at'];
                            return DMListItem(
                              user: user,
                              lastChecked: lastChecked,
                              endAt: endAt,
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