import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nutes/core/models/tab_item.dart';

List<BottomNavigationBarItem> items = [
  BottomNavigationBarItem(
    title: Text(''),
    icon: Icon(
      MdiIcons.homeOutline,
      color: Colors.black,
    ),
    activeIcon: Icon(
      MdiIcons.home,
      color: Colors.black,
    ),
  ),
  BottomNavigationBarItem(
    title: Text(''),
    icon: Icon(
      Feather.search,
      color: Colors.black,
    ),
    activeIcon: Icon(
      FontAwesome.search,
      color: Colors.black,
    ),
  ),
  BottomNavigationBarItem(
    title: Text(''),
    icon: Icon(
      Icons.add,
      color: Colors.black,
    ),
    activeIcon: Icon(
      FontAwesome.plus,
      color: Colors.black,
    ),
  ),
  BottomNavigationBarItem(
    title: Text(''),
    icon: Icon(
      MdiIcons.heartOutline,
      color: Colors.black,
    ),
    activeIcon: Icon(
      MdiIcons.heart,
      color: Colors.black,
    ),
  ),
  BottomNavigationBarItem(
    title: Text(''),
    icon: Icon(
      MdiIcons.accountOutline,
      color: Colors.black,
    ),
    activeIcon: Icon(
      MdiIcons.account,
      color: Colors.black,
    ),
  ),
];

///Helper class to work with tab items
class TabHelper {
  static TabItem item(int index) {
    switch (index) {
      case 0:
        return TabItem.home;
      case 1:
        return TabItem.search;
      case 2:
        return TabItem.create;
      case 3:
        return TabItem.activity;
      case 4:
        return TabItem.profile;
      default:
        return TabItem.home;
    }
  }
}

class BottomNavigation extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  const BottomNavigation({Key key, this.currentTab, this.onSelectTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[100]))),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab.index,
        items: items,
        onTap: (index) => onSelectTab(
          TabHelper.item(index),
        ),
      ),
    );
  }
}
