import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/home_model.dart';
import 'package:nutes/ui/screens/direct_screen.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/home_screen.dart';
import 'package:nutes/ui/shared/provider_view.dart';

class AppPageView extends StatefulWidget {
  @override
  _AppPageViewState createState() => _AppPageViewState();
}

class _AppPageViewState extends State<AppPageView> {
  //Ser initial page to the feed page
//  final _pageController = PageController(initialPage: 1);
  Widget _editorStoryScreen;

  final _focusNode = FocusScopeNode();
  final cache = LocalCache.instance;

  @override
  void initState() {
    _editorStoryScreen = FocusScope(
      node: _focusNode,
      child: EditorPage(
        isStoryMode: true,
        onBackPressed: () => cache.animateTo(1),
//        onBackPressed: () => _animateToPage(1),
      ),
    );

    ///listen to page scroll
    cache.appScrollController.addListener(() {
      if (cache.appScrollController.page.floor() != 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        FocusScope.of(context).setFirstFocus(_focusNode);
      }
    });
//    _pageController.addListener(() {
//      if (_pageController.page.floor() != 0) {
//        FocusScope.of(context).requestFocus(FocusNode());
//      } else {
//        FocusScope.of(context).setFirstFocus(_focusNode);
//      }
//    });

    super.initState();
  }

//  void _animateToPage(int page) {
//    _pageController.animateToPage(page,
//        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
//  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ProviderView<HomeModel>(builder: (context, model, child) {
        return PageView(
          dragStartBehavior: DragStartBehavior.down,
          physics: cache.physics,
          controller: cache.appScrollController,
          children: <Widget>[
            _editorStoryScreen,
            HomeScreen(
//              onCreatePressed: () => _animateToPage(0),
              onCreatePressed: () => cache.animateTo(0),

              ///Page view is scrollable only when on feed page
              ///TODO: disable scroll on push @@@ Make use of Dismissible to
              ///prevent app view swipe
              onTabTapped: (index) => setState(() {
                cache.physics = index == 0
                    ? ClampingScrollPhysics()
                    : NeverScrollableScrollPhysics();
              }),
            ),
            DirectScreen(
              onLeadingPressed: () => cache.animateTo(1),
//              onLeadingPressed: () => _animateToPage(1),
              onTrailingPressed: () {},
            ),
          ],
        );
      }),
    );
  }
}
