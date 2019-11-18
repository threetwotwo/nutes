import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/home_model.dart';
import 'package:nutes/core/view_models/login_model.dart';
import 'package:nutes/ui/screens/direct_screen.dart';
import 'package:nutes/ui/screens/editor_page.dart';
import 'package:nutes/ui/screens/home_screen.dart';
import 'package:nutes/ui/shared/provider_view.dart';
import 'package:provider/provider.dart';

class AppPageView extends StatefulWidget {
  final String uid;

  const AppPageView({Key key, this.uid}) : super(key: key);
  @override
  _AppPageViewState createState() => _AppPageViewState();
}

class _AppPageViewState extends State<AppPageView> {
  Widget _editorStoryScreen;

  final _focusNode = FocusScopeNode();
  final cache = LocalCache.instance;
  final auth = Auth.instance;

  _getProfile() async {
//    final model = Provider.of<LoginModel>(context);
//
//    final result = await Repo.getUserProfile(widget.uid);
//    print('current profile: ${result.toMap()}');
//    model.updateProfile(result);
    auth.profile = await Repo.getUserProfile(widget.uid);
    setState(() {});
  }

  @override
  void initState() {
//    final model = Provider.of<LoginModel>(context);
//
    if (auth.profile == null) _getProfile();
//    _getProfile();

    _editorStoryScreen = FocusScope(
      node: _focusNode,
      child: EditorPage(
        isStoryMode: true,
        onBackPressed: () => cache.animateTo(1),
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Auth.instance.profile == null
        ? CupertinoActivityIndicator()
        : WillPopScope(
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
