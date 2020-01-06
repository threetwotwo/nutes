import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nutes/ui/shared/post_grid_view.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/responsive.dart';

enum ViewType { list, grid }

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

class ProfileTabController extends StatefulWidget {
  final ViewType view;

  final PostGridView postGridView;
  final Widget postListView;

  ProfileTabController(
      {Key key,
      this.view,
      @required this.postGridView,
      @required this.postListView})
      : super(key: key);

  @override
  _ProfileTabControllerState createState() => _ProfileTabControllerState();
}

class _ProfileTabControllerState extends State<ProfileTabController> {
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
