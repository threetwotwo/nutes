import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/shout_screen.dart';
import 'package:nutes/ui/shared/large_header.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/create_screen_shout_item.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  List<User> followings = [];
  final auth = Repo.auth;

  Future<void> _getFollowings() async {
    final result = await Repo.getMyUserFollowings();
    setState(() {
      followings = result;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _getFollowings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                  stream: Repo.ShoutStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();

                    final docs = snapshot.data.documents;

                    if (docs.length < 1) return SizedBox();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        LargeHeader(title: 'Respond to a shout'),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 240,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: docs.length,
                                  itemBuilder: (context, idx) {
                                    final doc = docs[idx];

                                    final peer =
                                        User.fromMap(doc['user'] ?? {});

                                    final uid = auth.uid;

                                    final chatId =
                                        (uid.hashCode <= peer.uid.hashCode)
                                            ? '$uid-${peer.uid}'
                                            : '${peer.uid}-$uid';
                                    return InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          ShoutScreen.route(
                                            chatId: chatId,
                                            peer: peer,
                                            messageId: doc.documentID,
                                            content: doc['content'] ?? '',
                                            topic: doc['topic'] ?? '',
                                          )),
                                      child: CreateScreenShoutItem(
                                        user: peer,
                                        doc: doc,
                                      ),
                                    );
                                  })),
                        ),
                      ],
                    );
                  }),
              LargeHeader(title: 'Create'),
              Container(
                padding: const EdgeInsets.all(16),
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
//                      focusColor: Colors.pink,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.grey[100],
                      onTap: () => Navigator.of(context, rootNavigator: true)
                          .push(EditorPage.route()),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Create Post',
                                  style: TextStyles.w600Text.copyWith(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
//              if (_followings.isNotEmpty) LargeHeader(title: 'Start A Shout'),
//              Container(
//                padding: const EdgeInsets.all(16),
//                height: 180,
//                child: ListView.builder(
//                  itemCount: _followings.length,
//                  scrollDirection: Axis.horizontal,
//                  itemBuilder: (context, index) {
//                    final user = _followings[index];
//                    return InkWell(
//                      onTap: () =>
//                          Navigator.of(context).push(ChatScreen.route(user)),
//                      child: Column(
//                        children: <Widget>[
//                          Expanded(
//                              child: AvatarImage(
//                            url: user.urls.medium,
//                            spacing: 4.0,
//                          )),
//                          Padding(
//                            padding: const EdgeInsets.all(4.0),
//                            child: Text(
//                              user.username,
//                              style: TextStyles.w600Text,
//                            ),
//                          ),
//                        ],
//                      ),
//                    );
//                  },
//                ),
//              ),
            ],
          ),
        ),
      ),
    );
  }
}
