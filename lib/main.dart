import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/ui/widgets/app_page_view.dart';
import 'package:nutes/ui/screens/login_screen.dart';
import 'package:nutes/core/services/locator.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/feed_model.dart';
import 'package:nutes/core/view_models/login_model.dart';
import 'package:nutes/core/view_models/profile_model.dart';

import 'core/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUpLocator();

  await initCurrentUser();
  runApp(MyApp());
}

Future initCurrentUser() async {
  UserProfile user;

  ///check FIRAuth if user is signed in
//  final authUser = await locator<FirebaseAuth>().currentUser();

  final authUser = await FirebaseAuth.instance.currentUser();
  print('FIRUser = $authUser');
  if (authUser != null) {
    user = await Repo.getUserProfile(authUser.uid);

    Repo.currentProfile = user;
    Repo.myStory = null;

    if (user == null) locator<LoginModel>().signOut();

    LocalCache.instance = LocalCache();

    return;

//      Repo.myUserFollowings = await Repo.getMyUserFollowings(user.uid);

  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
//  final observer = locator<RouteObserver<PageRoute>>();

  bool isLoaded = false;

  @override
  void initState() {
    initCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainBuilder()
//          :
//            Scaffold(
//              body: Container(
//                  color: Colors.white,
//                  child: Center(
//                      child: Text(
//                    'nutes',
//                    style: TextStyles.large600Display.copyWith(fontSize: 38),
//                  ))),
//            ),
//      theme: ThemeData(
//          fontFamily: '.SF UI Display',
//          iconTheme: IconThemeData(
//            color: Colors.black,
//          ),
//          buttonTheme: ButtonThemeData(
//            buttonColor: Colors.black,
//          )),
        );
  }
}

class MainBuilder extends StatefulWidget {
  @override
  _MainBuilderState createState() => _MainBuilderState();
}

class _MainBuilderState extends State<MainBuilder> {
  final _auth = locator<LoginModel>();

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
        ChangeNotifierProvider<FeedModel>(builder: (context) => FeedModel()),
        ChangeNotifierProvider<ProfileModel>(
            builder: (context) => locator<ProfileModel>()),
      ],
      child: StreamBuilder<FirebaseUser>(
        stream: _auth.auth.onAuthStateChanged,
        builder: (context, snapshot) {
          print(snapshot);
//          if (!snapshot.hasData) {
//            print(' auth user not initialized');
//            return Scaffold(
//              body: Container(
////                color: Colors.white,
//                child: Center(child: Text('HOHOHOH')),
//              ),
//            );
//          }

          if (snapshot.hasData) {
            return AppPageView();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
