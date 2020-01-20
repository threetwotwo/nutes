import 'package:flutter/cupertino.dart';

class LoadingIndicator extends StatelessWidget {
  final double padding;

  const LoadingIndicator({Key key, this.padding = 16}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}
