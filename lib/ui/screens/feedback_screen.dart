import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/empty_indicator.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/shared/styles.dart';

class FeedbackScreen extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => FeedbackScreen());

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(
          'Feedback',
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
                  final text = controller.text;

                  if (text.isEmpty) return Navigator.pop(context);

                  PlatformException error;

                  await Repo.sendFeedback(text).catchError((e) {
                    print(e);
                    error = e;
                    throw (e);
                  });

                  setState(() {
                    isLoading = false;
                  });

                  if (error == null) {
                    BotToast.showText(
                        text: 'Thanks so much for your feedback!');

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
                  'Briefly explain what you like, or what could improve'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 52,
                    child: AvatarImage(
                      padding: 4,
                      url: FirestoreService.ath.user.urls.small,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        maxLines: 8,
                        maxLength: 2000,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintText: 'Feedback',
                          counterText: '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
