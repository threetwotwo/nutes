import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/logos.dart';

class FeedPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onCreatePressed;
  final Function onLogoutPressed;

  const FeedPageAppBar({Key key, this.onCreatePressed, this.onLogoutPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.create),
        onPressed: onCreatePressed,
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
