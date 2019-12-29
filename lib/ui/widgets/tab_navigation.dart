import 'package:flutter/material.dart';
import 'package:nutes/core/models/tab_item.dart';
import 'package:nutes/ui/screens/activity_screen.dart';
import 'package:nutes/ui/screens/feed_screen.dart';
import 'package:nutes/ui/screens/my_profile_screen.dart';
import 'package:nutes/ui/screens/search_screen.dart';
import 'package:nutes/ui/screens/create_screen.dart';

class HomeRoute {
  static const String root = '/';
}

class SearchRoute {
  static const String root = '/';
}

class CreateRoute {
  static const String root = '/';
}

class ActivityRoute {
  static const String root = '/';
}

class ProfileRoute {
  static const String root = '/';
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;
  final PageController pageController;
  final VoidCallback onCreatePressed;
  final VoidCallback onDM;

  final routeObserver = RouteObserver<PageRoute>();

  TabNavigator({
    this.navigatorKey,
    this.tabItem,
    this.pageController,
    this.onCreatePressed,
    this.onDM,
  });

  Map<String, Widget> _routeBuilders(BuildContext context, TabItem tabItem) {
    switch (tabItem) {
      case TabItem.home:
        return {
          HomeRoute.root: FeedScreen(
//            navigatorKey: this.navigatorKey,
            onCreatePressed: onCreatePressed,
            onDM: onDM,
          ),
        };
      case TabItem.search:
        return {
          SearchRoute.root: SearchScreen(),
        };
      case TabItem.create:
        return {
          CreateRoute.root: CreateScreen(),
        };
      case TabItem.activity:
        return {
          ActivityRoute.root: ActivityScreen(),
        };
      case TabItem.profile:
        return {
          ProfileRoute.root: MyProfileScreen(isRoot: true),
        };
    }
  }

//  final observer = locator<RouteObserver<PageRoute>>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: HomeRoute.root,
      observers: tabItem == TabItem.home ? [] : [],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) =>
              _routeBuilders(context, tabItem)[routeSettings.name],
        );
      },
    );
  }
}
