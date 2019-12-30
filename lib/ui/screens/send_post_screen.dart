import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/post.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/search_bar.dart';
import 'package:nutes/ui/shared/styles.dart';

class SendPostScreen extends StatefulWidget {
  final Post post;

  const SendPostScreen({Key key, this.post}) : super(key: key);

  static Route route(Post post) => MaterialPageRoute(
      builder: (context) => SendPostScreen(post: post), fullscreenDialog: true);

  @override
  _SendPostScreenState createState() => _SendPostScreenState();
}

class _SendPostScreenState extends State<SendPostScreen> {
  final _searchController = TextEditingController();
  final _messageController = TextEditingController();

  final searchFocusNode = FocusNode();

  List<User> users = [];

  List<User> filteredUsers = [];
  List<User> searchedUsers = [];

  List<User> tappedUsers = [];

  Future<void> _send() async {
    final uid = Auth.instance.profile.uid;

    final futures = tappedUsers.map((peer) {
      final chatId = (uid.hashCode <= peer.uid.hashCode)
          ? '$uid-${peer.uid}'
          : '${peer.uid}-$uid';

      return Repo.uploadMessage(
        ref: Repo.createMessageRef(chatId),
        type: Bubbles.post,
        content: _messageController.text,
        peer: peer,
        data: widget.post.toMap(),
      );
    });

    return Future.wait(futures);
  }

  void _onTap(User user) {
    final tapped = tappedUsers.contains(user);

    final isSearched = !users.contains(user);

    setState(() {
      tapped
          ? tappedUsers.removeWhere((id) => id == user)
          : tappedUsers.add(user);

      if (isSearched) users.insert(0, user);

      _searchController.clear();

      searchedUsers.clear();
      filteredUsers.clear();
    });
  }

  Future<void> _getUsers() async {
    final result = await Repo.getMyUserFollowings();
    setState(() {
      users = result;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        automaticallyImplyLeading: false,
        title: SearchBar(
          controller: _searchController,
          onTextChange: (text) async {
            if (text.isEmpty)
              setState(() {
                searchedUsers.clear();
              });

            final filtered =
                users.where((user) => user.username.startsWith(text)).toList();

            if (filtered.isEmpty && text.isNotEmpty) {
              final result = await Repo.searchUsers(text);
              setState(() {
                searchedUsers = result;
              });
              print('should do search');
            }
            print(filtered);

            setState(() {
              filteredUsers = filtered;
            });
          },
          showCancelButton: searchFocusNode.hasFocus,
          onCancel: () {
            _searchController.clear();
          },
        ),
        trailing: FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyles.defaultText,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ListView.builder(
                itemCount: searchedUsers.isNotEmpty
                    ? searchedUsers.length
                    : filteredUsers.isNotEmpty
                        ? filteredUsers.length
                        : users.length,
                itemBuilder: (context, index) {
                  final user = searchedUsers.isNotEmpty
                      ? searchedUsers[index]
                      : filteredUsers.isNotEmpty
                          ? filteredUsers[index]
                          : users[index];
                  final tapped = tappedUsers.contains(user);

                  return AvatarListItem(
                    avatar: AvatarImage(
                      url: user.urls.small,
                    ),
                    title: user.username,
                    trailingWidget: InkWell(
                      onTap: () => _onTap(user),
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: tapped ? Colors.blueAccent : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  tapped ? Colors.transparent : Colors.black),
                        ),
                        child: tapped
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : SizedBox(),
                      ),
                    ),
                  );
                }),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (tappedUsers.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200])),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyles.defaultText,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Message',
                        ),
                      ),
                    ),
                  InkWell(
                    highlightColor: Colors.blue,
                    splashColor: Colors.blue,
                    onTap: () {
                      if (tappedUsers.isEmpty) return;
                      BotToast.showText(text: 'Sent', align: Alignment.center);
                      _send();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 45,
                      color: Colors.blueAccent[200].withOpacity(0.8),
                      child: Center(
                        child: Text(
                          tappedUsers.length > 1
                              ? 'Send separately (${tappedUsers.length})'
                              : 'Send',
                          style: TextStyles.defaultText
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
