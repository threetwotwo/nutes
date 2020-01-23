import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/ui/widgets/login_textfield.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();

  static Route route() =>
      MaterialPageRoute(builder: (context) => ContactUsScreen());
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  bool isLoading = false;

  final emailController = TextEditingController();
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Contact Us',
          style: TextStyles.header,
        ),
        trailing: isLoading
            ? LoadingIndicator()
            : FlatButton(
                child: Text(
                  'Done',
                  style: TextStyles.defaultText.copyWith(color: Colors.blue),
                ),
                onPressed: () async {
                  final email = emailController.text;
                  final message = messageController.text;

                  if (email.isEmpty || message.isEmpty)
                    return Navigator.pop(context);

                  PlatformException error;

                  await Repo.sendSupportMessage(email, message).catchError((e) {
                    error = e;
                    throw (e);
                  });

                  setState(() {
                    isLoading = false;
                  });

                  if (error == null) {
                    BotToast.showText(
                        text: 'Your message will be reviewed shortly');

                    return Navigator.pop(context);
                  } else
                    return null;
                },
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              EmptyIndicator(
                  'Let us know of any problems or requests, or if you want to make changes to your account'),
              ContactTextField(
                controller: emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              ContactTextField(
                controller: messageController,
                keyboardType: TextInputType.multiline,
                hint: 'Message',
                maxLines: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactTextField extends StatelessWidget {
  final String hint;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final int maxLength;
  final int maxLines;

  const ContactTextField(
      {Key key,
      this.hint,
      this.keyboardType,
      this.controller,
      this.maxLength,
      this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        autocorrect: false,
        maxLength: maxLength ?? 254,
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType,
        controller: controller,
        style: TextStyles.defaultText,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          hintText: hint,
        ),
      ),
    );
  }
}
