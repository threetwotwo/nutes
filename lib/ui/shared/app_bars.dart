import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/logos.dart';
import 'package:nutes/ui/shared/styles.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading;
  final Widget trailing;
  final Widget title;

  final VoidCallback onLeadingPressed;
  final VoidCallback onTrailingPressed;

  const BaseAppBar(
      {Key key,
      this.leading,
      this.trailing,
      this.title,
      this.onLeadingPressed,
      this.onTrailingPressed})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: GestureDetector(
        onTap: onLeadingPressed ?? () => Navigator.of(context).pop(),
        child: leading == null
            ? Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )
            : leading,
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GestureDetector(
            child: trailing == null ? SizedBox() : trailing,
            onTap: onTrailingPressed,
          ),
        )
      ],
      title: title,
      elevation: 1.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
    );
  }
}

class EditProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onCancelPressed;
  final Function onDonePressed;

  const EditProfileAppBar(
      {Key key, @required this.onCancelPressed, @required this.onDonePressed})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BaseAppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: onCancelPressed,
        color: Colors.black,
        tooltip: 'Cancel',
      ),
      title: NutesLogoPlain(),
      trailing: Tooltip(
        message: "Done",
        child: FlatButton(
          child: Text(
            'Done',
            style: TextStyles.w300Display.copyWith(color: Colors.blueAccent),
          ),
          onPressed: onDonePressed,
        ),
      ),
    );
  }
}

class CameraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onCameraPressed;
  final Function onLogoutPressed;

  const CameraAppBar({Key key, this.onCameraPressed, this.onLogoutPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.create),
        onPressed: onCameraPressed,
        color: Colors.black,
        tooltip: 'Camera',
      ),
      title: NutesLogoPlain(),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: onLogoutPressed,
          color: Colors.black,
        )
      ],
      elevation: 1.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onLeadingPressed;
  final Function onTrailingPressed;
  final bool isRoot;

//  final title;
//  final isVerified;
  final UserProfile profile;

  const ProfileAppBar({
    Key key,
    this.onLeadingPressed,
    this.onTrailingPressed,
//    this.title,
//    this.isVerified,
    @required this.profile,
    @required this.isRoot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isRoot
        ? AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.transparent,
              ),
              onPressed: onLeadingPressed,
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
            iconTheme: IconThemeData(color: Colors.black),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  LineIcons.bars,
                  color: Colors.black,
                ),
                onPressed: onTrailingPressed,
              )
            ],
            elevation: 1.5,
            brightness: Brightness.light,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${profile.user.username}',
                  style: TextStyles.defaultDisplay.copyWith(fontSize: 18),
                ),
                if (profile.isVerified) ...[
                  SizedBox(width: 4),
                  Icon(
                    MdiIcons.checkDecagram,
                    color: Colors.blueAccent,
                    size: 20,
                  )
                ],
              ],
            ),
            backgroundColor: Colors.white)
        : BaseAppBar(
            title: Text(
              profile.user.username,
              style: TextStyles.W500Text15.copyWith(fontSize: 16),
            ),
            onTrailingPressed: () {
              final route = ModalRoute.of(context);
              print(route.isFirst);
            },
          );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class BottomBar extends StatefulWidget {
  final int currentIndex;
  final double iconSize;
  final Color backgroundColor;
  final List<BottomBarItem> items;
  final ValueChanged<int> onItemSelected;

  BottomBar(
      {Key key,
      this.currentIndex = 0,
      this.iconSize = 24,
      this.backgroundColor,
      @required this.items,
      @required this.onItemSelected}) {
    assert(items != null);
    assert(items.length >= 2 || items.length >= 5);
    assert(onItemSelected != null);
  }

  @override
  _BottomBarState createState() {
    return _BottomBarState(
        items: items,
        backgroundColor: backgroundColor,
        currentIndex: currentIndex,
        iconSize: iconSize,
        onItemSelected: onItemSelected);
  }
}

class _BottomBarState extends State<BottomBar> {
  final int currentIndex;
  final double iconSize;
  Color backgroundColor;
  List<BottomBarItem> items;
  int _selectedIndex;
  ValueChanged<int> onItemSelected;

  _BottomBarState(
      {@required this.items,
      this.currentIndex,
      this.backgroundColor,
      this.iconSize,
      @required this.onItemSelected});

  Widget _buildItem(BottomBarItem item, bool isSelected) {
    final expandedWidth = MediaQuery.of(context).size.width / 3.2;
    return AnimatedContainer(
      width: isSelected ? expandedWidth : 50,
      height: double.maxFinite,
      duration: Duration(milliseconds: 180),
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color:
            isSelected ? item.activeColor.withOpacity(0.08) : backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(50)),
        border: isSelected
            ? Border.all(width: 1.25, color: item.activeColor.withOpacity(0.0))
            : null,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconTheme(
                  data: IconThemeData(
                      size: iconSize,
                      color: isSelected
                          ? item.activeColor.withOpacity(1)
                          : item.inactiveColor == null
                              ? item.activeColor
                              : item.inactiveColor),
                  child: isSelected ? item.activeIcon : item.inactiveIcon,
                ),
              ),
              isSelected
                  ? DefaultTextStyle.merge(
                      style: TextStyle(
                          color: item.activeColor, fontWeight: FontWeight.w600),
                      child: item.title,
                    )
                  : SizedBox.shrink()
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    _selectedIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor = (backgroundColor == null)
        ? Theme.of(context).bottomAppBarColor
        : backgroundColor;

    return BottomAppBar(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.all(8),
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((item) {
            var index = items.indexOf(item);
            return GestureDetector(
              onTap: () {
                onItemSelected(index);

                setState(() {
                  _selectedIndex = index;
                });
              },
              child: _buildItem(item, _selectedIndex == index),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomBarItem {
  final Icon inactiveIcon;
  final Icon activeIcon;
  final Text title;
  final Color activeColor;
  final Color inactiveColor;

  BottomBarItem(
      {@required this.inactiveIcon,
      @required this.activeIcon,
      @required this.title,
      this.activeColor = Colors.blue,
      this.inactiveColor}) {
    assert(inactiveIcon != null);
    assert(title != null);
  }
}
