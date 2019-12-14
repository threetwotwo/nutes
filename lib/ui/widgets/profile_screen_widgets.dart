import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/post_grid_view.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/responsive.dart';

enum ViewType { list, grid }

class BioHeader extends StatelessWidget {
  final UserProfile user;
  final Function onMorePressed;

  const BioHeader({
    Key key,
    @required this.user,
    this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size(double size) {
      return screenAwareSize(size, context);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                user.user.displayName ?? '',
                style: TextStyles.w600Text.copyWith(fontSize: 15),
              ),
              IconButton(
                onPressed: onMorePressed,
                icon: Icon(
                  MdiIcons.chevronDown,
                  size: defaultSize(24, context, defaultTo: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileTabBar extends StatelessWidget {
  final ViewType view;
  final Function onPressed;

  const ProfileTabBar({Key key, this.view, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color activeColorForView(ViewType view) {
      return this.view == view ? ColorStyles.darkPurple : Colors.black26;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            MdiIcons.gridLarge,
            color: activeColorForView(ViewType.grid),
            size: defaultSize(24, context, defaultTo: 20),
          ),
          onPressed: () {
            return onPressed(ViewType.grid);
          },
        ),
        IconButton(
          icon: Icon(
            MdiIcons.viewDay,
            color: activeColorForView(ViewType.list),
            size: defaultSize(24, context, defaultTo: 20),
          ),
          onPressed: () {
            return onPressed(ViewType.list);
          },
        ),
      ],
    );
  }
}

class PostMasterView extends StatefulWidget {
  final ViewType view;

  final PostGridView postGridView;
  final Widget postListView;

  PostMasterView(
      {Key key,
      this.view,
      @required this.postGridView,
      @required this.postListView})
      : super(key: key);

  @override
  _PostMasterViewState createState() => _PostMasterViewState();
}

class _PostMasterViewState extends State<PostMasterView> {
  ViewType view;

  @override
  void initState() {
    view = widget.view;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ProfileTabBar(
          view: view,
          onPressed: (ViewType view) {
            setState(() {
              this.view = view;
            });
          },
        ),
        Container(
            child: view == ViewType.grid
                ? widget.postGridView
                : widget.postListView),
      ],
    );
  }
}
