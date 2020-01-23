import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/account_settings_screen.dart';
import 'package:nutes/ui/screens/change_password_screen.dart';
import 'package:nutes/ui/screens/help_screen.dart';
import 'package:nutes/ui/screens/info_screen.dart';
import 'package:nutes/ui/screens/privacy_policy_screen.dart';
import 'package:nutes/ui/screens/privacy_screen.dart';
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
//            AccountListTile(LineIcons.bookmark_o, 'Saved'),
//            AccountListTile(
//              LineIcons.gear,
//              'Settings',
//              onTap: () => Navigator.push(
//                context,
//                AccountSettingsScreen.route(profile),
//              ),
//            ),
            AccountListTile(
              LineIcons.shield,
              'Privacy',
              onTap: () => Navigator.push(
                context,
                PrivacyScreen.route(),
              ),
            ),
            AccountListTile(
              LineIcons.key,
              'Password',
              onTap: () => Navigator.push(
                context,
                ChangePasswordScreen.route(),
              ),
            ),

            AccountListTile(
              LineIcons.question_circle,
              'Help',
              onTap: () => Navigator.push(
                context,
                HelpScreen.route(),
              ),
            ),
            AccountListTile(
              LineIcons.info_circle,
              'Info',
              onTap: () => Navigator.push(
                context,
                InfoScreen.route(),
              ),
            ),

            AccountListTile(
              LineIcons.sign_out,
              'Sign Out',
              onTap: () => showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  content: Text('Are you sure you want to sign out?'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                      isDefaultAction: true,
                    ),
                    CupertinoDialogAction(
                      child: Text('Sign Out'),
                      isDestructiveAction: true,
                      onPressed: () async {
                        await Repo.logout();
                        return Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(icon, size: 28),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      title,
                      style: TextStyles.defaultText.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
