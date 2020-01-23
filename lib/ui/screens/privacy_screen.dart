import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/ui/screens/account_screen.dart';
import 'package:nutes/ui/screens/account_settings_screen.dart';
import 'package:nutes/ui/screens/blocked_accounts_screen.dart';
import 'package:nutes/ui/screens/contact_us_screen.dart';
import 'package:nutes/ui/screens/feedback_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class PrivacyScreen extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => PrivacyScreen());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Privacy',
          style: TextStyles.header,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            AccountListTile(
              LineIcons.lock,
              'Account Privacy',
              onTap: () => Navigator.push(
                  context, AccountSettingsScreen.route(FirestoreService.ath)),
            ),
            AccountListTile(
              LineIcons.times_circle,
              'Blocked Accounts',
              onTap: () =>
                  Navigator.push(context, BlockedAccountsScreen.route()),
            ),
          ],
        ),
      ),
    );
  }
}
