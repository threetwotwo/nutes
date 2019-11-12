import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutes/core/models/tab_item.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/core/view_models/home_model.dart';
import 'package:nutes/ui/screens/create_screen.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/widgets/bottom_navigation.dart';
import 'package:nutes/ui/widgets/tab_navigation.dart';

class HomeScreen extends StatefulWidget {
  final Function onTabTapped;
  final Function onCreatePressed;

  const HomeScreen({Key key, this.onTabTapped, this.onCreatePressed})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  PageController pageController = PageController();

  CreateScreen draftPage = CreateScreen();

  var currentTab = TabItem.home;

  Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.search: GlobalKey<NavigatorState>(),
    TabItem.create: GlobalKey<NavigatorState>(),
    TabItem.activity: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    print('home disposed');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = Provider.of<HomeModel>(context);
    final cache = LocalCache.instance;

    return Scaffold(
      bottomNavigationBar: BottomNavigation(
        currentTab: currentTab,
        onSelectTab: (tab) {
          ///Change scroll physics depending on current tab
          model.changeScrollPhysics((tab == TabItem.home)
              ? ClampingScrollPhysics()
              : NeverScrollableScrollPhysics());

          ///Scroll up
          if (tab == currentTab) {
            switch (tab) {
              case TabItem.home:
                if (cache.homeIsFirst) cache.animateToTop(tab);

                break;
              case TabItem.search:
                cache.animateToTop(tab);
                break;
              case TabItem.create:
                break;
              case TabItem.activity:
                break;
              case TabItem.profile:
                cache.animateToTop(tab);

                break;
            }

            ///Pop until first
            _navigatorKeys[tab].currentState.popUntil((route) => route.isFirst);
          }

          setState(() {
            cache.physics = tab == TabItem.home
                ? ClampingScrollPhysics()
                : NeverScrollableScrollPhysics();
            return currentTab = tab;
          });

          return widget.onTabTapped(tab.index);
        },
      ),
      body: IndexedStack(
        index: TabItem.values.indexOf(currentTab),
        children: <Widget>[
          _buildOffstageNavigator(TabItem.home),
          _buildOffstageNavigator(TabItem.search),
          _buildOffstageNavigator(TabItem.create),
          _buildOffstageNavigator(TabItem.activity),
          _buildOffstageNavigator(TabItem.profile),
        ],
      ),
    );
  }

  ///Offstage to toggle visibility of current tab
  Widget _buildOffstageNavigator(TabItem tabItem) {
    return TabNavigator(
      navigatorKey: _navigatorKeys[tabItem],
      tabItem: tabItem,
      onCreatePressed: widget.onCreatePressed,
      onAddStoryPressed: widget.onCreatePressed,
    );
  }
}
