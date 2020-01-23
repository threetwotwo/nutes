import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/styles.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading;
  final Widget trailing;
  final Widget title;

  final VoidCallback onLeadingPressed;
  final VoidCallback onTrailingPressed;

  final bool automaticallyImplyLeading;
  final result;

  const BaseAppBar(
      {Key key,
      this.leading,
      this.trailing,
      this.title,
      this.onLeadingPressed,
      this.onTrailingPressed,
      this.automaticallyImplyLeading = true,
      this.result})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: !automaticallyImplyLeading
          ? null
          : GestureDetector(
              onTap:
                  onLeadingPressed ?? () => Navigator.of(context).pop(result),
              child: leading == null
                  ? Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    )
                  : leading,
            ),
      actions: <Widget>[
        GestureDetector(
          child: trailing == null ? SizedBox() : trailing,
          onTap: onTrailingPressed,
        )
      ],
      title: title,
      elevation: 1.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
    );
  }
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onLeadingPressed;
  final Function onTrailingPressed;
  final bool isRoot;

  final UserProfile profile;

  const ProfileAppBar({
    Key key,
    this.onLeadingPressed,
    this.onTrailingPressed,
    @required this.profile,
    @required this.isRoot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isRoot
        ? AppBar(
            automaticallyImplyLeading: true,
            leading: Icon(Icons.delete, color: Colors.transparent),
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
            title: Wrap(
              alignment: WrapAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (profile.user.isPrivate) Icon(Icons.lock, size: 17),
                Text(
                  '${profile.user.username}',
                  style: TextStyles.header,
                  overflow: TextOverflow.ellipsis,
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
              style: TextStyles.w600Text.copyWith(fontSize: 16),
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
