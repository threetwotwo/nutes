import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';

class SearchOverlay extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onUsername;

  const SearchOverlay({Key key, this.controller, this.onUsername})
      : super(key: key);

  @override
  _SearchOverlayState createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  List<User> users = [];

  bool isSearching = false;

  String searchText;

  final regex = RegExp(r"(?<!@)\B@[a-z\._0-9]*?$", caseSensitive: false);

  _search(String text) async {
    if (mounted)
      setState(() {
        isSearching = true;
      });
    print('search for users: $text');
    final result = await Repo.searchUsers(text);
    if (mounted)
      setState(() {
        isSearching = false;
        users = result;
      });
  }

  @override
  void initState() {
    widget.controller.addListener(() {
      final match =
          regex.stringMatch(widget.controller.text)?.replaceAll('@', '');
      if (mounted)
        setState(() {
          searchText = match;
        });
      if (searchText != null) _search(match);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: isSearching
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CupertinoActivityIndicator(),
                  SizedBox(width: 8),
                  Text(
                    'Searching for '
                    '\"${searchText}\"',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ))
          : users.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.controller.text.length < 2 ? '' : 'No users found',
                    style: TextStyle(color: Colors.grey),
                  ))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Material(
                      child: InkWell(
                        onTap: () => widget.onUsername('@${user.username}'),
                        child: AvatarListItem(
                          avatar: AvatarImage(
                            url: user.photoUrl,
                          ),
                          title: user.username,
                          subtitle: user.displayName,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
