import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/screens/account_settings_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:flutter/cupertino.dart';

class AccountScreen extends StatelessWidget {
  final UserProfile profile;

  static Route route(UserProfile user) =>
      MaterialPageRoute(builder: (context) => AccountScreen(profile: user));

  const AccountScreen({Key key, this.profile}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
          title: Text(
            'Account',
            style: TextStyles.header,
          ),
        ),
        body: ListView(
          children: <Widget>[
            AccountListTile(LineIcons.bookmark_o, 'Saved'),
            AccountListTile(LineIcons.gear, 'Settings',
                onTap: () => Navigator.push(
                    context, AccountSettingsScreen.route(profile))),
          ],
        ));
  }
}

class AccountListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AccountListTile(this.icon, this.title, {this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(icon, size: 28),
                  ),
                  Text(
                    title,
                    style: TextStyles.defaultText.copyWith(fontSize: 16),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
//    return ListTile(
//      onTap: () => Navigator.of(context).push(
//        MaterialPageRoute(builder: (context) => onTap),
//      ),
//      leading: Icon(
//        icon,
//        size: 30,
//        color: Colors.black87,
//      ),
//      title: Text(
//        title,
//        style: TextStyles.defaultText,
//      ),
//    );
  }
}
