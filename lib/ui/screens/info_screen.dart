import 'package:flutter/material.dart';
import 'package:nutes/ui/screens/account_screen.dart';
import 'package:nutes/ui/screens/privacy_policy_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class InfoScreen extends StatelessWidget {
  static Route route() => MaterialPageRoute(builder: (context) => InfoScreen());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Info and Privacy',
          style: TextStyles.header,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            AccountListTile(
              null,
              'Info',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Nutes',
                  applicationVersion: 'version 1.0.3',
                );
              },
            ),
            AccountListTile(
              null,
              'Privacy Policy',
              onTap: () => Navigator.push(context, PrivacyPolicyScreen.route()),
            ),
          ],
        ),
      ),
    );
  }
}
