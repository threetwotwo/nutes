import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

const List<BottomNavigationBarItem> items = [
  BottomNavigationBarItem(
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

class BottomDefaultBar extends StatelessWidget {
  final Function(int) onTap;

  const BottomDefaultBar({Key key, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      onTap: onTap,
      items: items,
    );
  }
}
