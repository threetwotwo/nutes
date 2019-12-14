import 'package:flutter/material.dart';
import 'package:nutes/core/models/filter.dart';
import 'package:nutes/core/models/tab_item.dart';

class LocalCache {
  ScrollPhysics physics = ClampingScrollPhysics();

  static var instance = LocalCache();

  Map<int, Map<int, Filter>> filters = {};

  List<String> postLikes = [];

  bool homeIsFirst = true;
  bool searchIsFirst = true;
  bool createIsFirst = true;
  bool activityIsFirst = true;
  bool profileIsFirst = true;

  int searchTabIndex = 0;

  PageController appScrollController = PageController(initialPage: 1);

  ScrollController homeScrollController = ScrollController();
  ScrollController searchPopularScrollController = ScrollController();
  ScrollController searchSubmittedScrollController = ScrollController();
  ScrollController profileScrollController = ScrollController();

  static const scrollDuration = Duration(milliseconds: 400);
  static const scrollCurve = Curves.easeInOut;

  void reset() {
    LocalCache.instance = LocalCache();
  }

  Future animateTo(int page) {
    print('animate app to page $page');
    if (appScrollController.hasClients)
      return appScrollController.animateToPage(page,
          duration: scrollDuration, curve: scrollCurve);
    else
      return null;
  }

  void animateToTop(TabItem tabItem) {
    print('scroll up for $tabItem');
    ScrollController controller;

    print(tabItem);
    switch (tabItem) {
      case TabItem.home:
        controller = instance.homeScrollController;
        break;
      case TabItem.search:
        controller = searchTabIndex == 0
            ? instance.searchPopularScrollController
            : instance.searchSubmittedScrollController;
        break;
      case TabItem.create:
        break;
      case TabItem.activity:
        break;
      case TabItem.profile:
        controller = instance.profileScrollController;
        break;
    }

    ///Scroll up
    if (controller.hasClients)
      controller.animateTo(0, duration: scrollDuration, curve: scrollCurve);
  }
}
