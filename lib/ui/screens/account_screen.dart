import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/screens/account_settings_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:flutter/cupertino.dart';

class AccountScreen extends StatelessWidget {
  final UserProfile user;

  static Route route(UserProfile user) =>
      MaterialPageRoute(builder: (context) => AccountScreen(user: user));

  const AccountScreen({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(),
        body: ListView(
          children: <Widget>[
            AccountListTile(LineIcons.bookmark_o, 'Saved'),
            AccountListTile(
              LineIcons.gear,
              'Settings',
              onTap: AccountSettingsScreen(
                profile: this.user,
              ),
            ),
          ],
        ));
  }
}

class AccountListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget onTap;

  const AccountListTile(this.icon, this.title, {this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => onTap),
      ),
      leading: Icon(
        icon,
        size: 30,
        color: Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyles.w300Display,
      ),
    );
  }
}
