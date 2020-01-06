import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class ChangeUsernameScreen extends StatefulWidget {
  final UserProfile profile;

  const ChangeUsernameScreen({Key key, this.profile}) : super(key: key);

  static Route route(UserProfile profile) => MaterialPageRoute(
      builder: (context) => ChangeUsernameScreen(
            profile: profile,
          ));

  @override
  _ChangeUsernameScreenState createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final controller = TextEditingController();

  bool hasError = false;

  bool isCheckingUsername = false;

  @override
  void initState() {
    controller.text = widget.profile.user.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Username',
          style: TextStyles.header,
        ),
        trailing: isCheckingUsername
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
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              TextField(
                controller: controller,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp("[a-z\._0-9]")),
                ],
                decoration: InputDecoration(
                  suffix: InkWell(
                    onTap: onCancel,
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(8),
                  labelText:
                      hasError ? 'This username is not available' : 'Username',
                  hintText: ('Enter a new username'),
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
    if (controller.text == widget.profile.user.username)
      return Navigator.pop(context);

    setState(() {
      isCheckingUsername = true;
    });

    if (controller.text.length < 2) {
      setState(() {
        isCheckingUsername = false;
        hasError = true;
      });
      return;
    }

    final exists = await Repo.usernameExists(controller.text);

    setState(() {
      isCheckingUsername = false;
      hasError = exists;
    });
  }
}
