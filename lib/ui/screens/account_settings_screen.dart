import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class AccountSettingsScreen extends StatefulWidget {
  final UserProfile profile;

  const AccountSettingsScreen({Key key, this.profile}) : super(key: key);
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool isPrivate;

  @override
  void initState() {
    isPrivate = widget.profile.user.isPrivate ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              trailing: CupertinoSwitch(
                  value: isPrivate,
                  onChanged: (val) {
                    setState(() {
                      isPrivate = val;
                    });

                    Repo.updateAccountPrivacy(val);
                  }),
              title: Text(
                'Private Account',
                style: TextStyles.w300Display,
              ),
              subtitle: Text(isPrivate ? 'private' : 'public'),
            )
          ],
        ),
      ),
    );
  }
}
