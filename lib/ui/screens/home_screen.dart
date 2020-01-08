import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/screens/activity_screen.dart';
import 'package:nutes/ui/screens/feed_screen.dart';
import 'package:nutes/ui/screens/my_profile_screen.dart';
import 'package:nutes/ui/screens/search_screen.dart';
import 'package:nutes/core/models/tab_item.dart';
import 'package:nutes/core/services/local_cache.dart';
import 'package:nutes/ui/screens/create_screen.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) onTabTapped;
  final VoidCallback onCreatePressed;
  final VoidCallback onDM;

  const HomeScreen({
    Key key,
    this.onTabTapped,
    this.onCreatePressed,
    this.onDM,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  PageController pageController = PageController();

  CreateScreen draftPage = CreateScreen();

  var currentTab = TabItem.home;

  Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(debugLabel: 'home'),
    TabItem.search: GlobalKey<NavigatorState>(),
    TabItem.create: GlobalKey<NavigatorState>(),
    TabItem.activity: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  };

  final homeScrollController = ScrollController();
  final explorePopularScrollController = ScrollController();
  final exploreNewestScrollController = ScrollController();
  final profileScrollController = ScrollController();

  ///Current search tab index
  int searchTabIndex = 0;

  int currentIndex = 0;

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

  void _animateToTop(TabItem tab) {
    print('scroll up for $tab');
    ScrollController controller;

    print(tab);
    switch (tab) {
      case TabItem.home:
        controller = homeScrollController;
        break;
      case TabItem.search:
        controller = searchTabIndex == 0
            ? explorePopularScrollController
            : exploreNewestScrollController;
        break;
      case TabItem.create:
        break;
      case TabItem.activity:
        break;
      case TabItem.profile:
        controller = profileScrollController;
        break;
    }

    ///Scroll up
    if (controller.hasClients)
      controller.animateTo(0, duration: scrollDuration, curve: scrollCurve);
  }

//  final observer = locator<RouteObserver<PageRoute>>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profile = Provider.of<UserProfile>(context);

    final cache = LocalCache.instance;

    return WillPopScope(
      onWillPop: () async {
        final currentNav = _navigatorKeys[currentTab];

        final canPop = currentNav.currentState.canPop();

        if (canPop) currentNav.currentState.pop();

        return !canPop;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigation(
          currentTab: currentTab,
          onSelectTab: (tab) {
            ///Scroll up
            if (tab == currentTab) {
              switch (tab) {
                case TabItem.home:
                  if (cache.homeIsFirst) _animateToTop(tab);

                  break;
                case TabItem.search:
                  cache.animateToTop(tab);
                  break;
                case TabItem.create:
                  break;
                case TabItem.activity:
                  break;
                case TabItem.profile:
                  _animateToTop(tab);

                  break;
              }

              ///Pop until first
              _navigatorKeys[tab]
                  .currentState
                  .popUntil((route) => route.isFirst);
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
            ///Home

            Navigator(
              key: _navigatorKeys[TabItem.home],
              initialRoute: '/',
              observers: [],
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => FeedScreen(
//                    profile: profile,
                    scrollController: homeScrollController,
                    onCreatePressed: widget.onCreatePressed,
                    onDM: widget.onDM,
                    onDoodleStart: () {
                      print('home on doodle');
                      setState(() {
                        cache.physics = NeverScrollableScrollPhysics();
                      });
                    },
                  ),
                );
              },
            ),

            ///Search
            Navigator(
              key: _navigatorKeys[TabItem.search],
              initialRoute: '/',
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    onTab: (idx) {
                      setState(() {
                        searchTabIndex = idx;
                      });
                    },
                  ),
                );
              },
            ),

            ///Create
            Navigator(
              key: _navigatorKeys[TabItem.create],
              initialRoute: '/',
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => CreateScreen(),
                );
              },
            ),

            ///Activity
            Navigator(
              key: _navigatorKeys[TabItem.activity],
              initialRoute: '/',
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => ActivityScreen(),
                );
              },
            ),

            ///Profile
            Navigator(
              key: _navigatorKeys[TabItem.profile],
              initialRoute: '/',
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => MyProfileScreen(
//                    profile: profile,
                    scrollController: profileScrollController,
                    isRoot: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
