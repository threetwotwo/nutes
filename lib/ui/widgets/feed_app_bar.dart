import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nutes/ui/shared/logos.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onCreatePressed;
  final Function onLogoutPressed;
  final Function onDM;
  final bool hasUnread;

  const FeedAppBar(
      {Key key,
      this.onCreatePressed,
      this.onLogoutPressed,
      this.onDM,
      this.hasUnread})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(MdiIcons.pencilPlus),
        onPressed: onCreatePressed,
        color: Colors.black,
      ),
      title: NutesLogoPlain(),
      actions: <Widget>[
//        IconButton(
//          icon: Icon(SimpleLineIcons.logout),
//          onPressed: onLogoutPressed,
//          color: Colors.black,
//        ),
        Stack(
          children: <Widget>[
            Center(
              child: IconButton(
                icon: Icon(
                  SimpleLineIcons.paper_plane,
                ),
                onPressed: onDM,
                color: Colors.black,
              ),
            ),
            if (hasUnread)
              Positioned.fill(
                top: 13,
                right: 8,
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.blue,
                  ),
                ),
              )
          ],
        ),
      ],
      elevation: 1.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
