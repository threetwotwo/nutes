import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/search_result_view.dart';

class SearchOverlay extends StatefulWidget {
  final Widget child;

  final TextEditingController controller;
  final Function onScroll;

  const SearchOverlay({
    Key key,
    @required this.controller,
    @required this.onScroll,
    @required this.child,
  }) : super(key: key);

  @override
  _SearchOverlayState createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  bool showSearchScreen = false;
  final regex = RegExp(r"(?<!@)\B@[a-z\._0-9]*?$", caseSensitive: false);
  String searchText;

  @override
  void initState() {
    widget.controller.addListener(() {
      if (widget.controller.text.contains(regex)) {
        final match = regex.stringMatch(widget.controller.text);
        if (mounted)
          setState(() {
            searchText = match;
          });
        setState(() {
          showSearchScreen = true;
        });
      } else
        setState(() {
          showSearchScreen = false;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        NotificationListener(
          onNotification: (t) {
            if (t is UserScrollNotification) {
              FocusScope.of(context).requestFocus(FocusNode());
              return widget.onScroll == null ? null : widget.onScroll();
            }
            return null;
          },
          child: widget.child,
        ),
        if (showSearchScreen)
          Positioned.fill(
              child: Column(
            children: <Widget>[
              Expanded(
                child: SearchResultView(
                  controller: widget.controller,
                  onUsername: (val) {
                    final text = widget.controller.text;

                    final lastIndex = text.lastIndexOf(" ");

                    widget.controller.text =
                        text.substring(0, lastIndex < 0 ? 0 : lastIndex) +
                            '${lastIndex < 0 ? '' : ' '}$val ';
                    setState(() {
                      showSearchScreen = false;
                    });
                  },
                ),
              ),
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: widget.controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: 'Add a caption',
                  ),
                ),
              )
            ],
          )),
      ],
    );
  }
}
