import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:provider/provider.dart';
import 'core/models/user.dart';
import 'core/services/firestore_service.dart';

final auth = Auth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//  await initCurrentUser();

  runApp(MyApp());
}

Future initCurrentUser() async {
  UserProfile user;

  ///check FIRAuth if user is signed in

  final authUser = await FirebaseAuth.instance.currentUser();

  if (authUser != null) {
    user = await Repo.getUserProfile(authUser.uid);

    Repo.auth = user;
    FirestoreService.auth = user;

    Repo.myStory = null;

    if (user == null) FirebaseAuth.instance.signOut();

    LocalCache.instance = LocalCache();

    return;
  }
}

Future<dynamic> _handleMessage(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];

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
//        Navigator.of(context).push(ProfileScreen.route(extraData));

        break;
      default:
        break;
    }
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
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
  final auth = Repo.auth;
  final _fcm = FirebaseMessaging();
  IosNotificationSettings iosSettings;
  String fcmToken;

  UserProfile profile;

  _createFCMToken() async {
    final user = await FirebaseAuth.instance.currentUser();

    if (user != null) Repo.createFCMDeviceToken(user.uid, fcmToken);
  }

  @override
  void initState() {
    super.initState();

    _fcm.requestNotificationPermissions();

    _fcm.getToken().then((String token) {
      assert(token != null);
      fcmToken = token;
//      Repo.fcmToken = fcmToken;
      FirestoreService.FCMToken = fcmToken;
      print('FCM token: $token');
    });

    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
      iosSettings = settings;

      if (iosSettings != null && fcmToken != null) _createFCMToken();
    });

    _fcm.configure(
//      onBackgroundMessage: _handleMessage,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
//        _handleMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
//        _handleMessage(message);
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

//        if (snapshot.data != null) _getProfile(snapshot.data.uid);

        return StreamBuilder<DocumentSnapshot>(
            stream: Repo.userProfileStream(snapshot.data.uid),
            builder: (context, snap) {
              if (!snap.hasData)
                return Scaffold(
                    body: Container(
                  color: Colors.white,
                  child: Center(
                    child: LoadingIndicator(),
                  ),
                ));
              final profile = UserProfile.fromDoc(snap.data);

              if (profile == null) Repo.logout();

              Repo.auth = profile;
              FirestoreService.auth = profile;

              print('@@@@@@ #### stream profile: ${profile.uid}');
              return profile == null
                  ? Scaffold(
                      body: Container(
                        color: Colors.white,
                        child: Center(
                          child: LoadingIndicator(),
                        ),
                      ),
                    )
                  : Provider<UserProfile>(
                      create: (BuildContext context) => profile,
                      child: AppPageView(
                        uid: snapshot.data.uid,
                      ),
                    );
            });
      },
    );
  }

//  Future<void> _getProfile(String uid) async {
//    print('#### Get Profile for $uid');
//    final result = await Repo.getUserProfile(uid);
//
//    if (result == null)
//      await Repo.logout();
//    else {
//      Auth.instance.profile = result;
//
//      profile = result;
//
//      ///TODO: get rid of auth == null error
//
//      setState(() {});
//    }
//
//    return;
//  }
}
