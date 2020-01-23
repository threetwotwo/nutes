import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/styles.dart';

class ChangeBioScreen extends StatefulWidget {
  final UserProfile profile;

  const ChangeBioScreen({Key key, this.profile}) : super(key: key);

  static Route route(UserProfile profile) => MaterialPageRoute(
      builder: (context) => ChangeBioScreen(
            profile: profile,
          ));

  @override
  _ChangeBioScreenState createState() => _ChangeBioScreenState();
}

class _ChangeBioScreenState extends State<ChangeBioScreen> {
  final controller = TextEditingController();

  bool hasError = false;

  bool isChecking = false;

  String text = '';

  @override
  void initState() {
    controller.text = widget.profile.bio;

    controller.addListener(() {
      setState(() {
        text = controller.text;
      });
    });
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
                maxLength: 150,
                maxLines: 10,
                decoration: InputDecoration(
//                  counterText: (150 - text.length).toString(),
                  suffix: InkWell(
                    onTap: onCancel,
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(8),
//                  labelText:
//                      hasError ? 'This username is not available' : 'Username',
                  labelText: 'Bio',
                  hintText: ('Enter a bio'),
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
    if (controller.text == widget.profile.bio) return Navigator.pop(context);

//    setState(() {
//      isChecking = true;
//    });
//
//    if (controller.text.length < 2) {
//      setState(() {
//        isChecking = false;
//        hasError = true;
//      });
//      return;
//    }
//
//    final exists = await Repo.usernameExists(controller.text);
//
//    setState(() {
//      isChecking = false;
//      hasError = exists;
//    });
//
//    if (hasError) return;
//
//    setState(() {
//      isChecking = true;
//    });
//
//    UserProfile profile;
//    if (!hasError) {
//    }
//
//    setState(() {
//      isChecking = false;
//      hasError = exists;
//    });

    setState(() {
      isChecking = true;
    });

    final profile = await Repo.updateProfile(bio: controller.text);

    setState(() {
      isChecking = false;
    });
    return Navigator.pop(context, profile);
  }
}
