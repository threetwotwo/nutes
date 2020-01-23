import 'package:flutter/material.dart';
import 'package:nutes/ui/screens/account_screen.dart';
import 'package:nutes/ui/screens/contact_us_screen.dart';
import 'package:nutes/ui/screens/feedback_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class HelpScreen extends StatelessWidget {
  static Route route() => MaterialPageRoute(builder: (context) => HelpScreen());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Help',
          style: TextStyles.header,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            AccountListTile(
              null,
              'Send Feedback',
              onTap: () => Navigator.push(context, FeedbackScreen.route()),
            ),
            AccountListTile(
              null,
              'Contact Us',
              onTap: () => Navigator.push(context, ContactUsScreen.route()),
            ),
          ],
        ),
      ),
    );
  }
}
