import 'package:flutter/material.dart';
import 'package:nutes/core/models/tab_item.dart';
import 'base_model.dart';

class TabController {
  final bool isFirst;
  final scrollController = ScrollController();

  TabController({this.isFirst});

  TabController copyWith(bool isFirst) {
    return TabController(
      isFirst: isFirst ?? this.isFirst,
    );
  }
}

class HomeModel extends BaseModel {
  int currentIndex;

  ScrollPhysics scrollPhysics = ClampingScrollPhysics();

  final scrollController = ScrollController();

  bool isFirst = true;

  Map<TabItem, TabController> controllers = {
    TabItem.home: TabController(isFirst: true),
    TabItem.search: TabController(isFirst: true),
    TabItem.create: TabController(isFirst: true),
    TabItem.activity: TabController(isFirst: true),
    TabItem.profile: TabController(isFirst: true),
  };

  changeIsFirst(bool val) {
    isFirst = val;
    notifyListeners();
  }

  changeState(TabItem tab, bool isFirst) {
    controllers[tab] = controllers[tab].copyWith(isFirst);
    notifyListeners();
  }

  animateToTop(TabItem tab) {
    controllers[tab].scrollController.animateTo(0,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    notifyListeners();
  }

  changeScrollPhysics(ScrollPhysics physics) {
    print('INFO: change scroll physics to $physics');
    scrollPhysics = physics;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
