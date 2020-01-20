import 'package:flutter/material.dart';
import 'package:nutes/ui/screens/explore_screen.dart';
import 'package:nutes/ui/screens/search_results_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/search_bar.dart';
import 'package:nutes/ui/shared/styles.dart';

class SearchScreen extends StatefulWidget {
  final void Function(int) onTab;
  final ScrollController popularSearchController;
  final ScrollController newestSearchController;

  const SearchScreen(
      {Key key,
      this.onTab,
      this.popularSearchController,
      this.newestSearchController})
      : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  final _searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  int index = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    searchFocusNode.addListener(() {
      print('search has focus: ${searchFocusNode.hasFocus}');
      setState(() {
        index = searchFocusNode.hasFocus ? 1 : 0;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
          automaticallyImplyLeading: false,
          title: SearchBar(
            focusNode: searchFocusNode,
            controller: _searchController,
            onTextChange: (text) => print(text),
            showCancelButton: searchFocusNode.hasFocus,
            onCancel: () {
              _searchController.clear();
            },
          ),
          trailing: AnimatedOpacity(
            opacity: index == 1 ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: Visibility(
              visible: index == 1,
              child: CancelButton(onPressed: () {
                _searchController.clear();
                FocusScope.of(context).requestFocus(FocusNode());
              }),
            ),
          )),
      body: index == 0
          ? ExploreScreen(
              popularSearchController: widget.popularSearchController,
              newestSearchController: widget.newestSearchController,
              onTab: (idx) {
                print('on search tab $idx');
                return widget.onTab(idx);
              },
            )
          : SearchResultsScreen(controller: _searchController),
    );
  }

  Widget CancelButton({Function onPressed}) {
    return FlatButton(
      child: Text(
        'Cancel',
        style: TextStyles.w300Display,
      ),
      onPressed: onPressed,
    );
  }
}
