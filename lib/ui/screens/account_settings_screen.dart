import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class AccountSettingsScreen extends StatefulWidget {
  static Route route(UserProfile profile) =>
      MaterialPageRoute(builder: (context) => AccountSettingsScreen());
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Account Settings',
          style: TextStyles.header,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: Repo.myProfileStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();

            final isPrivate = snapshot.data['is_private'] ?? false;
            return Container(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    trailing: CupertinoSwitch(
                        value: isPrivate,
                        onChanged: (val) => Repo.updateAccountPrivacy(val)),
                    title: Text(
                      'Private Account',
                      style: TextStyles.w600Display,
                    ),
                    subtitle: Text('${isPrivate ? 'Private' : 'Public'} - '
                        '${isPrivate ? 'only people you approve can see your photos and stories' : 'anyone can see your photos and stories'}'),
                  )
                ],
              ),
            );
          }),
    );
  }
}
