import 'package:flutter/material.dart';
import 'package:nutes/ui/screens/explore_screen.dart';
import 'package:nutes/ui/screens/search_results_screen.dart';
import 'package:nutes/ui/shared/search_bar.dart';
import 'package:nutes/ui/shared/styles.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  final textEditingController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final _searchResultsScreen = SearchResultsScreen();
  final _exploreScreen = ExploreScreen();
  int index = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    textEditingController.addListener(() {
      setState(() {
        index = textEditingController.text.isEmpty ? 0 : 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SearchBar(
          focusNode: searchFocusNode,
          controller: textEditingController,
          onTextChange: (text) => print(text),
          onCancel: () {
            textEditingController.clear();
          },
        ),
        actions: <Widget>[
          CancelButton(onPressed: () {
            textEditingController.clear();
            FocusScope.of(context).requestFocus(FocusNode());
          })
        ],
      ),
      body: index == 0 ? _exploreScreen : _searchResultsScreen,
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
