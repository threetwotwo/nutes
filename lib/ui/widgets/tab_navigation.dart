import 'package:flutter/material.dart';
import 'package:nutes/core/models/tab_item.dart';
import 'package:nutes/core/services/locator.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/home_model.dart';
import 'package:nutes/ui/screens/account_screen.dart';
import 'package:nutes/ui/screens/activity_screen.dart';
import 'package:nutes/ui/screens/feed_screen.dart';
import 'package:nutes/ui/screens/my_profile_screen.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/screens/search_screen.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/create_screen.dart';

class HomeRoute {
  static const String root = '/';
  static const String user = '/user';
}

class SearchRoute {
  static const String root = '/';
  static const String user = '/user';
}

class CreateRoute {
  static const String root = '/';
  static const String user = '/user';
}

class ActivityRoute {
  static const String root = '/';
  static const String user = '/user';
}

class ProfileRoute {
  static const String root = '/';
  static const String user = '/user';
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;
  final PageController pageController;
  final VoidCallback onCreatePressed;
  final VoidCallback onAddStoryPressed;

  final routeObserver = RouteObserver<PageRoute>();

  final model = locator<HomeModel>();

  TabNavigator(
      {this.navigatorKey,
      this.tabItem,
      this.pageController,
      this.onCreatePressed,
      this.onAddStoryPressed});

  Map<String, Widget> _routeBuilders(BuildContext context, TabItem tabItem) {
    switch (tabItem) {
      case TabItem.home:
        return {
          HomeRoute.root: FeedScreen(
            navigatorKey: this.navigatorKey,
            onCreatePressed: onCreatePressed,
            onAddStoryPressed: onAddStoryPressed,
            routeObserver: routeObserver,
          ),
//          HomeRoute.user: (context) => ProfileScreen(),
        };
      case TabItem.search:
        return {
          SearchRoute.root: SearchScreen(),
//          SearchRoute.user: (context) => ProfileScreen(),
        };
      case TabItem.create:
        return {
          CreateRoute.root: CreateScreen(),
//          CreateRoute.user: (context) => ProfileScreen(),
        };
      case TabItem.activity:
        return {
          ActivityRoute.root: ActivityScreen(),
//          ActivityRoute.user: (context) => ProfileScreen(),
        };
      case TabItem.profile:
        print(Repo.currentProfile.toMap());
        return {
          ProfileRoute.root: MyProfileScreen(isRoot: true),
//          ProfileRoute.root: ProfileScreen(
//            isRoot: true,
//            uid: Repo.currentProfile.uid,
//            onTrailingPressed: () => Navigator.of(context, rootNavigator: true)
//                .push(MaterialPageRoute(
//                    builder: (context) => AccountScreen(
//                          user: Repo.currentProfile,
//                        ))),
//          ),
        };
    }
  }

  final observer = locator<RouteObserver<PageRoute>>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: HomeRoute.root,
      observers: tabItem == TabItem.home ? [observer] : [],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) =>
              _routeBuilders(context, tabItem)[routeSettings.name],
        );
      },
    );
  }
}
