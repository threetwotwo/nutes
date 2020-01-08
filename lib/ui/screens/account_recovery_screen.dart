import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/buttons.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/login_textfield.dart';

class AccountRecoveryScreen extends StatelessWidget {
  static Route route() => MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AccountRecoveryScreen(),
      );

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Account Recovery',
          style: TextStyles.header,
        ),
        leading: CancelButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            EmptyIndicator(
                'Forgot your password? Enter the email you used to register and you will be sent a link to reset your password'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: EmailTextField(
                controller: controller,
              ),
            ),
            FlatButton(
//              color: Colors.blueAccent,
              onPressed: () async {
                if (controller.text.isEmpty) return;
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: controller.text);
                BotToast.showText(text: 'Email sent!');

                Navigator.pop(context);
              },
              child: Text(
                'Send email',
                style: TextStyles.w600Text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
