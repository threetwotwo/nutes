import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class ChangeEmailScreen extends StatefulWidget {
//  final UserProfile profile;
  final String email;

  const ChangeEmailScreen({
    Key key,
//    this.profile,
    this.email,
  }) : super(key: key);

  static Route route(
//    UserProfile profile,
    String email,
  ) =>
      MaterialPageRoute(
          builder: (context) => ChangeEmailScreen(
//                profile: profile,
                email: email,
              ));

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final controller = TextEditingController();

  bool hasError = false;

  bool isChecking = false;

  String _email;

  String errorMessage = '';

  final passwordController = TextEditingController();

  void setErrorMessage(String msg) {
    setState(() {
      errorMessage = msg;
    });
  }

  @override
  void initState() {
    controller.text = widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Email',
          style: TextStyles.header,
        ),
        trailing: isChecking
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoActivityIndicator(),
              )
            : FlatButton(
                onPressed: onDone,
                child: Text(
                  'Done',
                  style:
                      TextStyles.defaultText.copyWith(color: Colors.blueAccent),
                ),
              ),
        result: _email,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              TextField(
                controller: controller,
//                inputFormatters: [
//                  WhitelistingTextInputFormatter(RegExp("[a-z\._0-9]")),
//                ],

                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.grey,
                    size: 18,
                  ),
                  suffix: InkWell(
                    onTap: onCancel,
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(8),
                  labelText: errorMessage.isEmpty ? 'Email' : errorMessage,
//                  labelText:
//                      hasError ? 'This username is not available' : 'Email',
                  hintText: ('Enter a valid email'),
                  labelStyle: TextStyles.defaultText.copyWith(
                    color: hasError ? Colors.red : Colors.grey,
                  ),
                  hintStyle:
                      TextStyles.defaultText.copyWith(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }

  void onCancel() {
    ///Weird error without callback
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      controller.clear();
    });
  }

  Future<void> onDone() async {
    if (controller.text == widget.email) return Navigator.pop(context);

    setState(() {
      isChecking = true;
    });

//    final isValid = EmailValidator.validate(controller.text);

    if (controller.text.length < 1) {
      setState(() {
        isChecking = false;
        hasError = true;
      });
      return;
    }

    PlatformException error;

    await Repo.updateEmail(controller.text.trim()).catchError((e) {
      if (e is PlatformException) {
        String message = '';
        switch (e.code) {
          case 'ERROR_INVALID_EMAIL':
            message = 'Please enter a valid email';
            break;

          case 'ERROR_REQUIRES_RECENT_LOGIN':
            message = 'This action requires authentication';
            showPasswordInput();
            break;

          case 'ERROR_EMAIL_ALREADY_IN_USE':
//          case 'ERROR_USER_NOT_FOUND':
            message = 'This email is already in user';
            break;

          default:
            message = 'Cannot change email. Please try again later.';
            break;
        }

        error = e;
        setErrorMessage(message);
      }
    });

//    final exists = await Repo.usernameExists(controller.text);

    setState(() {
      isChecking = false;
      hasError = error != null;
    });

    if (hasError) return;

    setState(() {
      isChecking = true;
    });

    setState(() {
      isChecking = false;
      hasError = error != null;
    });

    if (error == null) return Navigator.pop(context, controller.text);
  }

  void showPasswordInput() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Enter Password'),
            content: Material(
              child: CupertinoTextField(
                controller: passwordController,
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: Text('Done'),
                onPressed: () async {
                  final cred = await EmailAuthProvider.getCredential(
                    email: widget.email,
                    password: passwordController.text,
                  );
//                  return Navigator.pop(context);

                  final result =
                      await FirebaseAuth.instance.signInWithCredential(cred);

                  setErrorMessage('');
                  setState(() {
                    hasError = false;
                  });

                  print(result.user.uid);

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
