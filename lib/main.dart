import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/ui/widgets/app_page_view.dart';
import 'package:nutes/ui/screens/login_screen.dart';
import 'package:nutes/core/services/locator.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/login_model.dart';
import 'package:nutes/core/view_models/profile_model.dart';

import 'core/models/user.dart';

final auth = Auth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUpLocator();

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

    if (user == null) locator<LoginModel>().signOut();

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
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return BotToastInit(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainBuilder(),
      navigatorObservers: [BotToastNavigatorObserver()],
    ));
  }
}

class MainBuilder extends StatefulWidget {
  @override
  _MainBuilderState createState() => _MainBuilderState();
}

class _MainBuilderState extends State<MainBuilder> {
  final _auth = locator<LoginModel>();
  final auth = Auth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print('FCM token: $token');
    });
    super.initState();
  }

  @override
  void dispose() {
    print('Main builder disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginModel>(
            builder: (context) => locator<LoginModel>()),
        ChangeNotifierProvider<ProfileModel>(
            builder: (context) => locator<ProfileModel>()),
      ],
      child: StreamBuilder<FirebaseUser>(
        stream: _auth.auth.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return AppPageView(
              uid: snapshot.data.uid,
            );
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
