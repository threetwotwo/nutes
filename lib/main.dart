import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/widgets/app_page_view.dart';
import 'package:nutes/ui/screens/login_screen.dart';
import 'package:nutes/core/services/repository.dart';

import 'core/models/user.dart';

final auth = Auth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initCurrentUser();

  runApp(MyApp());
}

Future initCurrentUser() async {
  UserProfile user;

  ///check FIRAuth if user is signed in

  final authUser = await FirebaseAuth.instance.currentUser();

  if (authUser != null) {
    user = await Repo.getUserProfile(authUser.uid);

    auth.profile = user;
    Repo.myStory = null;

    if (user == null) FirebaseAuth.instance.signOut();

    LocalCache.instance = LocalCache();

    return;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoaded = false;

  @override
  void initState() {
    initCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return BotToastInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainBuilder(),
        navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }
}

class MainBuilder extends StatefulWidget {
  @override
  _MainBuilderState createState() => _MainBuilderState();
}

class _MainBuilderState extends State<MainBuilder> {
  final auth = Auth.instance;
  final _fcm = FirebaseMessaging();
  IosNotificationSettings iosSettings;
  String fcmToken;

  UserProfile profile;

  @override
  void initState() {
    super.initState();

    _fcm.requestNotificationPermissions();

    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
      iosSettings = settings;
    });

    _fcm.getToken().then((String token) {
      assert(token != null);
      fcmToken = token;
      auth.fcmToken = fcmToken;
      print('FCM token: $token');
    });

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> msg) async {
        print("onResume: $msg");

        final data = msg['data'] ?? {};
        final extraData = data['extradata'] ?? '';

        print('onResume screen: ${data['screen']}');
        switch (data['screen']) {
          case "dm":
            print('go to chat $extraData');
            break;
          case "post":
            print('go to post $extraData');
//            Navigator.of(context).push(PostDetailScreen.route(post));
            break;
          case "user":
            print('go to user $extraData');
            await Navigator.of(context).push(ProfileScreen.route(extraData));

            break;
          default:
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    print('Main builder disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoginScreen();

        if (iosSettings != null && fcmToken != null)
          Repo.createFCMDeviceToken(uid: snapshot.data.uid, token: fcmToken);

        if (snapshot.data != null && profile == null)
          _getProfile(snapshot.data.uid);

        return profile == null
            ? Scaffold(
                body: Container(
                  color: Colors.white,
                  child: Center(
                    child: LoadingIndicator(),
                  ),
                ),
              )
            : AppPageView(
                uid: snapshot.data.uid,
              );
      },
    );
  }

  Future<void> _getProfile(String uid) async {
    print('get profile of $uid');

    final result = await Repo.getUserProfile(uid);

    if (result == null)
      await Repo.logout();
    else {
      Auth.instance.profile = result;

      profile = result;

      ///TODO: get rid of auth == null error
//      await Future.delayed(Duration(milliseconds: 300));

      setState(() {});
    }

    return;
  }
}
