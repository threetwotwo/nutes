import 'package:flutter/material.dart';

class ImageDetailScreen extends StatelessWidget {
  final String url;

  const ImageDetailScreen({Key key, @required this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        body: GestureDetector(
      onHorizontalDragDown: (_) => Navigator.pop(context),
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.grey[900],
        width: deviceSize.width,
        height: deviceSize.height,
        child: SafeArea(
          child: Center(
            child: Hero(
              tag: url,
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
