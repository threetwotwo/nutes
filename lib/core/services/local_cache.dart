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

  PageController appScrollController = PageController(initialPage: 1);

  ScrollController homeScrollController = ScrollController();
  ScrollController searchScrollController = ScrollController();
  ScrollController profileScrollController = ScrollController();

  static const scrollDuration = Duration(milliseconds: 300);
  static const scrollCurve = Curves.easeInOut;

  void animateTo(int page) {
    print('animate app to page $page');
    appScrollController.animateToPage(page,
        duration: scrollDuration, curve: scrollCurve);
  }

  void animateToTop(TabItem tabItem) {
    ScrollController controller;

    print(tabItem);
    switch (tabItem) {
      case TabItem.home:
        controller = instance.homeScrollController;
        break;
      case TabItem.search:
        controller = instance.searchScrollController;
        break;
      case TabItem.create:
        break;
      case TabItem.activity:
        break;
      case TabItem.profile:
        controller = instance.profileScrollController;
        break;
    }

    ///Scroll up if the controller is attached to a scroll view
    if (controller.hasClients)
      controller.animateTo(0, duration: scrollDuration, curve: scrollCurve);
  }
}
