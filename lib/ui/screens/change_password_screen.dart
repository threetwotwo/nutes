import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/ui/screens/account_recovery_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class ChangePasswordScreen extends StatefulWidget {
//  final UserProfile profile;
//  final String email;

  const ChangePasswordScreen({
    Key key,
//    this.profile,
//    this.email,
  }) : super(key: key);

  static Route route(
//    UserProfile profile,
          ) =>
      MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(
//                profile: profile,
//                email: email,
              ));

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatPasswordcontroller = TextEditingController();

  bool hasError = false;

  bool isChecking = false;

  String _email;

  String errorMessage = '';

  void setErrorMessage(String msg) {
    setState(() {
      errorMessage = msg;
    });
  }

  @override
  void initState() {
//    controller.text = widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Change password',
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
                controller: currentPasswordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  suffix: InkWell(
                    onTap: () => onCancel(currentPasswordController),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(8),
                  labelText: 'Current Password',
                  hintStyle:
                      TextStyles.defaultText.copyWith(color: Colors.grey),
                ),
              ),
              TextField(
                controller: newPasswordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  suffix: InkWell(
                    onTap: () => onCancel(newPasswordController),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(8),
                  labelText: 'New Password',
                  hintStyle:
                      TextStyles.defaultText.copyWith(color: Colors.grey),
                ),
              ),
              TextField(
                controller: repeatPasswordcontroller,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  suffix: InkWell(
                    onTap: () => onCancel(repeatPasswordcontroller),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(8),
                  labelText: 'New Password again',
                  hintStyle:
                      TextStyles.defaultText.copyWith(color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              FlatButton(
                onPressed: () {
                  return Navigator.of(context, rootNavigator: true)
                      .push(AccountRecoveryScreen.route());
                },
                child: Text(
                  'Forgot Password',
                  style: TextStyles.w600Text.copyWith(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onCancel(TextEditingController controller) {
    ///Weird error without callback
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      controller.clear();
    });
  }

  Future<void> onDone() async {
//    if (controller.text == widget.email) return Navigator.pop(context);

    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final repeatPassword = repeatPasswordcontroller.text;

    if (newPassword != repeatPassword)
      setErrorMessage('Passwords do not match');
    if (newPassword.isEmpty) setErrorMessage('New password must not empty');

//    final isValid = EmailValidator.validate(controller.text);

    if (errorMessage.isNotEmpty) return showErrorMessage();

    setState(() {
      isChecking = true;
    });

    final user = await FirebaseAuth.instance.currentUser();

    ///Check if current password is correct
    final cred = EmailAuthProvider.getCredential(
      email: user.email,
      password: currentPassword,
    );

    final result = await FirebaseAuth.instance
        .signInWithCredential(cred)
        .catchError((err) {
      print(err);
      if (err is PlatformException) {
        switch (err.code) {
//                  case 'ERROR_WRONG_PASSWORD':
//                  case 'ERROR_INVALID_CREDENTIAL':
//                    setErrorMessage('You have entered a wrong password.');
//                    break;
          default:
            setErrorMessage(err.message);

            break;
        }
        showErrorMessage();

        return;
      }
    });

    if (result != null)
      await user.updatePassword(newPassword).catchError((e) async {
        if (e is PlatformException) {
          setErrorMessage(e.message);

          switch (e.code) {
            case 'ERROR_REQUIRES_RECENT_LOGIN':
              setErrorMessage('Require login');

              break;
            case 'ERROR_WEAK_PASSWORD':
              setErrorMessage('Password length must be at least 6 characters');

              break;
            default:
              setErrorMessage(e.message);
          }

          showErrorMessage();
        }
      });

    setState(() {
      isChecking = false;
    });

    if (errorMessage.isEmpty) {
      BotToast.showText(
          text: 'Password successfully changed', align: Alignment.center);
      Navigator.pop(context);
    }
  }

  void showErrorMessage() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Text(errorMessage),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  setErrorMessage('');
                  return Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
