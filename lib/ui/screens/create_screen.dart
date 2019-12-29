import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/chat_screen.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/large_header.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/timeAgo.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  List<User> _followings = [];
  final auth = Auth.instance;

  Future<void> _getFollowings() async {
    final result = await Repo.getMyUserFollowings();
    setState(() {
      _followings = result;
    });
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

                                    final user =
                                        User.fromMap(doc['user'] ?? {});

                                    return InkWell(
                                      onTap: () => Navigator.push(
                                          context, ChatScreen.route(user)),
                                      child: Container(
                                        width: 240,
                                        margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              user.urls.medium,
                                            ),
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                              Colors.black54,
                                              BlendMode.multiply,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                InkWell(
                                                  onTap: () => Navigator.push(
                                                      context,
                                                      ProfileScreen.route(
                                                          user.uid)),
                                                  child: Container(
                                                    height: 64,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            AvatarImage(
                                                              url: user
                                                                  .urls.small,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  user.username,
                                                                  style: TextStyles
                                                                      .w600Text
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  TimeAgo
                                                                      .formatLong(
                                                                    (doc['timestamp']
                                                                            as Timestamp)
                                                                        .toDate(),
                                                                  ),
                                                                  style: TextStyles
                                                                      .defaultText
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            Repo.deleteShout(
                                                                doc.documentID);
                                                          },
                                                          icon: Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
//                                            width: 160,
                                                    color: Colors.white,
                                                    height: 1,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Text(
                                                    doc['content'] ?? '',
                                                    maxLines: 4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyles
                                                        .defaultText
                                                        .copyWith(
                                                      color: Colors.white,
//                                              fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text(
                                                doc['topic'] ?? '',
                                                maxLines: 1,
                                                style: TextStyles.w600Display
                                                    .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
