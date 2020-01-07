import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/direct_screen.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/home_screen.dart';

const scrollDuration = Duration(milliseconds: 300);
const scrollCurve = Curves.easeInOut;

class AppPageView extends StatefulWidget {
  final String uid;

  const AppPageView({Key key, this.uid}) : super(key: key);
  @override
  _AppPageViewState createState() => _AppPageViewState();
}

class _AppPageViewState extends State<AppPageView> {
  final _focusNode = FocusScopeNode();

  ScrollPhysics scrollPhysics = ClampingScrollPhysics();

  final appPageController = PageController(initialPage: 1);

  UserProfile profile;

  Future animateTo(int page) {
    print('animate app to page $page');
    if (appPageController.hasClients)
      return appPageController.animateToPage(page,
          duration: scrollDuration, curve: scrollCurve);
    else
      return null;
  }

  _getProfile() async {
    final result = await Repo.getUserProfile(widget.uid);
    Auth.instance.profile = result;
    if (mounted)
      setState(() {
        profile = result;
      });
  }

  @override
  void initState() {
//
//    if (auth == null)
    _getProfile();
//
//    _editorStoryScreen = FocusScope(
//      node: _focusNode,
//      child: EditorPage(
//        isStoryMode: true,
//        onBackPressed: () => cache.animateTo(1),
//      ),
//    );

    ///listen to page scroll
    appPageController.addListener(() {
      if (context == null) return;
      if (appPageController.page.floor() != 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        FocusScope.of(context).setFirstFocus(_focusNode);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: scrollPhysics,
      controller: appPageController,
      children: <Widget>[
        FocusScope(
          node: _focusNode,
          child: EditorPage(
            isStoryMode: true,
            onBackPressed: () => animateTo(1),
          ),
        ),
        HomeScreen(
          onCreatePressed: () => animateTo(0),
          onDM: () => animateTo(2),

          ///Page view is scrollable only when on feed page
          onTabTapped: (index) => setState(() {
            scrollPhysics = index == 0
                ? ClampingScrollPhysics()
                : NeverScrollableScrollPhysics();
          }),
        ),
        DirectScreen(
          onLeadingPressed: () => animateTo(1),
          onTrailingPressed: () {},
        ),
      ],
    );
  }
}
