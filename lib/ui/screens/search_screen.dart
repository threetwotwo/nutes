import 'package:flutter/material.dart';
import 'package:nutes/ui/screens/explore_screen.dart';
import 'package:nutes/ui/screens/search_results_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
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
            controller: textEditingController,
            onTextChange: (text) => print(text),
            showCancelButton: searchFocusNode.hasFocus,
            onCancel: () {
              textEditingController.clear();
            },
          ),
          trailing: AnimatedOpacity(
            opacity: index == 1 ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: Visibility(
              visible: index == 1,
              child: CancelButton(onPressed: () {
                textEditingController.clear();
                FocusScope.of(context).requestFocus(FocusNode());
              }),
            ),
          )),
      body: index == 0
          ? ExploreScreen()
          : SearchResultsScreen(controller: textEditingController),
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
