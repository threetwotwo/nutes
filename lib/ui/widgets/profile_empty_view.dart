import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/styles.dart';

class ProfileEmptyView extends StatelessWidget {
  final User user;

  const ProfileEmptyView({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Text(
            'No Posts Yet\n',
            style: TextStyles.w600Text,
          ),
          Text(
            'When ${user.username} posts, you will see their photos here',
            style: TextStyles.defaultText.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
